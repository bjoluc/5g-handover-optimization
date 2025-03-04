#include <omp.h>

#include <iostream>
#include <random>
#include <vector>

using namespace std;

class IatGenerator {
 private:
  random_device randomDevice;
  mt19937 generator;
  exponential_distribution<double> distribution;

 public:
  IatGenerator(double iat)
      : generator(mt19937(randomDevice())),
        distribution(exponential_distribution(1 / iat)) {}

  long sample() {
    long iat;
    do {
      iat = (long)round(this->distribution(this->generator));
    } while (iat == 0);
    // cout << to_string((long)iat) << endl;
    return iat;
  }
};

class AbstractTimer {
 protected:
  unsigned int timerValue = 0;
  virtual void onTimerExpired() {};

 public:
  bool isRunning() { return this->timerValue > 0; }

  /**
   * @brief Advances the timer and returns true if it expires, false otherwise
   */
  bool step() {
    if (this->isRunning()) {
      this->timerValue--;
      if (this->timerValue == 0) {
        this->onTimerExpired();
        return true;
      }
    }

    return false;
  }
};

class Timer : public AbstractTimer {
 private:
  unsigned int duration;

 public:
  Timer(unsigned int duration) : duration(duration) {}

  void set() { this->timerValue = this->duration; }
};

class PoissonArrivals : public AbstractTimer {
 private:
  IatGenerator iatGenerator;
  unsigned long iat;

 protected:
  void sampleIat() { this->timerValue = this->iatGenerator.sample(); }
  void onTimerExpired() override { this->sampleIat(); };

 public:
  PoissonArrivals(unsigned long iat)
      : iatGenerator(IatGenerator(iat)), iat(iat) {
    this->sampleIat();
  }
};

class FixedRateArrivals : public AbstractTimer {
 private:
  unsigned int iat;

 protected:
  void onTimerExpired() override { this->timerValue = this->iat; };

 public:
  FixedRateArrivals(unsigned int iat, unsigned int firstIat = 0) : iat(iat) {
    this->timerValue = firstIat > 0 ? firstIat : this->iat;
  }
};

class UE {
 private:
  Timer inactivityTimer;
  Timer onDurationTimer;
  PoissonArrivals ulArrivals;
  PoissonArrivals dlArrivals;

  bool isDlPacketBufferedAtBS = false;

 public:
  UE(unsigned int iatUl, unsigned int iatDl, unsigned int onDuration,
     unsigned int inactivityTimer)
      : inactivityTimer(Timer(inactivityTimer)),
        onDurationTimer(Timer(onDuration)),
        ulArrivals(PoissonArrivals(iatUl)),
        dlArrivals(PoissonArrivals(iatDl)) {};

  bool isActive = true;

  void startNewCycle() {
    // On duration starts in this slot
    this->onDurationTimer.set();
    this->isActive = true;

    // UE receives buffered DL traffic, if any
    if (this->isDlPacketBufferedAtBS) {
      this->inactivityTimer.set();
      this->isDlPacketBufferedAtBS = false;
    }
  }

  void step() {
    bool doesOnDurationTimerExpire = this->onDurationTimer.step();
    bool doesInactivityTimerExpire = this->inactivityTimer.step();
    bool doesUlPacketArrive = this->ulArrivals.step();
    bool doesDlPacketArriveAtBS = this->dlArrivals.step();

    // Handle on duration and inactivity timer expiry
    if ((doesOnDurationTimerExpire || doesInactivityTimerExpire) &&
        !(this->inactivityTimer.isRunning() ||
          this->onDurationTimer.isRunning())) {
      this->isActive = false;
    }

    if (doesUlPacketArrive) {
      if (!this->isActive) {
        this->isActive = true;

        // UE receives any buffered DL traffic too:
        this->isDlPacketBufferedAtBS = false;
      }

      this->inactivityTimer.set();
    }

    if (doesDlPacketArriveAtBS) {
      if (this->isActive) {
        this->inactivityTimer.set();
      } else {
        this->isDlPacketBufferedAtBS = true;
      }
    }
  }
};

vector<double> estimate_activity_probabilities(
    unsigned long cycles, unsigned int cycleDuration, unsigned int onDuration,
    unsigned int inactivityTimer, unsigned int iatUl, unsigned int iatDl) {
  // All times are provided as number of slots (0.5ms)

  vector<double> slotActivities = vector((int)cycleDuration, 0.0);

#pragma omp parallel
  {
    UE ue = UE(iatUl, iatDl, onDuration, inactivityTimer);
    vector<double> slotActivitiesPrivate = vector((double)cycleDuration, 0.0);

#pragma omp for schedule(static, 100000)
    for (unsigned long cycle = 0; cycle < cycles; cycle++) {
      ue.startNewCycle();
      for (unsigned int slot = 0; slot < cycleDuration; slot++) {
        ue.step();
        if (ue.isActive) {
          slotActivitiesPrivate[slot]++;
        }
      }
    }

#pragma omp critical
    {
      for (unsigned int i = 0; i < cycleDuration; i++) {
        slotActivities[i] += slotActivitiesPrivate[i];
      }
    }
  }

  return slotActivities;
};

/**
 * @brief Returns a tuple of the sleep ratio and the average number of sleep
 * periods per DRX cycle.
 */
pair<double, double> estimate_sleep_ratio(
    unsigned long cycles, unsigned int cycleDuration, unsigned int onDuration,
    unsigned int inactivityTimer, unsigned int iatUl, unsigned int iatDl) {
  // All times are provided as number of slots (0.5ms)

  unsigned long sleepPeriodsCount = 0;
  unsigned long sleepSlots = 0;

#pragma omp parallel
  {
    UE ue = UE(iatUl, iatDl, onDuration, inactivityTimer);
    bool wasUeActiveInPreviousSlot = true;

#pragma omp for reduction(+ : sleepPeriodsCount) reduction(+ : sleepSlots)
    for (unsigned long cycle = 0; cycle < cycles; cycle++) {
      ue.startNewCycle();
      for (unsigned int slot = 0; slot < cycleDuration; slot++) {
        ue.step();

        if (ue.isActive) {
          if (!wasUeActiveInPreviousSlot) {
            wasUeActiveInPreviousSlot = true;
          }
        } else {
          sleepSlots++;
          if (wasUeActiveInPreviousSlot) {
            sleepPeriodsCount++;
            wasUeActiveInPreviousSlot = false;
          }
        }
      }
    }
  }

  return make_pair((double)sleepSlots / (cycles * cycleDuration),
                   (double)sleepPeriodsCount / cycles);
};

vector<bool> simulate_activity(unsigned long cycles, unsigned int cycleDuration,
                               unsigned int onDuration,
                               unsigned int inactivityTimer, unsigned int iatUl,
                               unsigned int iatDl) {
  // All times are provided as number of slots (0.5ms)

  vector<bool> activities = vector((int)cycleDuration * (int)cycles, false);
  UE ue = UE(iatUl, iatDl, onDuration, inactivityTimer);

  for (unsigned long cycle = 0; cycle < cycles; cycle++) {
    ue.startNewCycle();
    for (unsigned int slot = 0; slot < cycleDuration; slot++) {
      ue.step();

      if (ue.isActive) {
        activities[cycle * cycleDuration + slot] = true;
      }
    }
  }

  return activities;
};