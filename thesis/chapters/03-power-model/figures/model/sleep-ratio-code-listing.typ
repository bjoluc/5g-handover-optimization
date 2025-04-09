#import "@preview/codelst:2.0.2": sourcecode

#figure(caption: [Sleep Ratio Simulation Logic], placement: auto)[
  #sourcecode[```cpp
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
  ```]
] <lstSleepRatioCore>