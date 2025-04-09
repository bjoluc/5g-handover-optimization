#import "/utils.typ": nobreak

= Stochastic DRX Sleep Ratio Analysis <appendixSleepRatio>

This section explores analytical approaches to derive the #[@drx]-induced sleep ratio $r_"sleep"$ based on the packet inter-arrival times $T_P_D$ and $T_P_U$ in combination with the @drx parameters $T_C$, $T_I$, and $T_"On"$, as listed in @tabPowerModelParameters.

== Expectation-Based Approach

Let $t_a$ and $t_s$ be random variables, where $t_a$ denotes the duration of a @drx active period and $t_s$ denotes the time the @ue spends in a sleep state between two active periods.
The ratio of sleep time can thus be expressed as

$
r_"sleep" := EE[t_s] / (EE[t_a] + EE[t_s])
$

To calculate $r_"sleep"$, subsequently, the expectation values for $t_a$ and $t_s$ are derived based on the input parameters.
Assume that at least one packet is transmitted at the beginning of a @drx active period #footnote[All packets from the previous sleep duration are received in a batch at the beginning of the On duration and will be considered as one transmission for brevity, assuming the base station schedules as many packets as feasible in one slot.].
This can be either an @ul packet which arrives in a @drx sleep period and resets the inactivity timer #footnote[Technically, it is the @ul grant that resets the inactivity timer, but assuming that the scheduling delay does not vary significantly between @ul packets, @ul grants can be considered to have the same probability distribution as @ue @ul packet arrivals.], or a (possibly buffered) @dl packet arriving at the beginning of a @drx On duration.

Every packet arrival (@ul or @dl) after the first transmission resets the inactivity timer and therefore contributes to the active time $t_a$.
Therefore, $t_a$ can be decomposed as the sum of a number of packet inter-arrival times $t_P_i$, each shorter than the inactivity timer $T_I$, plus one final $T_I$ for timer expiry:

$
t_a = sum_(i=1)^(N) (t_P_i) + T_I
$ <equation-ta-sum>

#include "./figures/drx-active-period.typ"

@figDrxActivePeriod depicts this scenario with $N = 4$ packet arrivals (marked by arrows on the time axis) after the initial transmission at the beginning of the active period.
Both @ul and @dl packet arrivals are modeled as Poisson processes.
Let $A_U (t)$ and $A_D (t)$ be random variables denoting the number of @ul packet arrivals at the @ue and @dl packet arrivals at the @bs, respectively, during time $t$:

$
A_U (t) tilde.op italic("Poisson")(t/T_P_U), space
A_D (t) tilde.op italic("Poisson")(t/T_P_D)
$

Due to the properties of the Poisson distribution, the number of @ul and @dl packet arrivals $A(t)$ in time $t$ is known to be Poisson-distributed as well.

$
A_U (t) + A_D (t) =: A(t) tilde.op italic("Poisson")(t/lambda) "with"
lambda := 1/(1/T_P_U + 1/T_P_D)
$

Inter-arrival times of a Poisson distribution are exponentially distributed with the inverse of the distribution's parameter, i.e., $italic("Exp")(lambda)$ in case of @ul/@dl packet inter-arrival times.
However, this does not fully apply to the series of random variables $t_P_i$ which are each known to be shorter than the inactivity timer $T_I$.
Therefore, the distribution of $t_P_i$ is truncated at $T_I$:

$
t_P_i tilde.op italic("TExp")(lambda, T_I)
$

The expectation of a right-truncated exponential distribution can be derived by conditioning on the probability that a value lies within the truncation range:

$
"Let" X "be a r.v. with" X tilde.op italic("Exp")(lambda). \
EE[X | x <= c] = (integral_0^c x lambda e^(-lambda x))/PP(X <= c)
= ((1 - e^(-lambda c) (lambda c + 1)) / lambda) / (1 - e^(-lambda c))
= underbrace(
  1/lambda,
  EE[X]
)
dot.op
underbrace(
  (1 - e^(-lambda c) (lambda c + 1)) / (1 - e^(-lambda c)),
  "truncation factor" lt.eq 1
)
$

Next, the distribution of the random variable $N$, measuring the number of timer-resetting packet arrivals within $t_a$, needs to be determined.
Due to the memoryless property of the Poisson distribution, the probability for another packet to arrive within $T_I$ after the previous packet's arrival is equal for each packet.
Using the random variable $A(t)$ from above, it can be written as $PP(A(T_I) > 0)$.
Thus, whether the inactivity timer expires after receiving packet $i$ can be modeled as a Bernoulli trial with the success probability $p$ where

$
p = PP(A(T_I) = 0) = e^(-T_I/lambda)
$

$N$ is therefore the number of Bernoulli trials needed to gain a "success" outcome (i.e., the inactivity timer expires) and is known to be geometrically distributed:

$
N tilde.op G(e^(-T_I/lambda)) => EE[N] = 1/e^(-T_I/lambda) = e^(T_I/lambda)
$

Based on @equation-ta-sum, we can derive the expectation of $t_a$ as

$
EE[t_a]
= EE[sum_(i=1)^(N) (t_P_i) + T_I]
= EE[N] dot EE[t_P_i] + T_I 
= e^(T_I/lambda) dot (1 - e^(-lambda c) (lambda c + 1)) / (lambda (1 - e^(-lambda c))) + T_I
$

Each @drx active pediod $t_a$ is followed by a sleep period $t_s$.
The duration of the sleep period depends on when the next active period starts.
This may either be the case due to an @ul packet arrival, or due to the beginning of the next On duration, as demonstrated in @figDrxSleepPeriod.

#include "./figures/drx-sleep-period.typ"

Let the random variables $t_P_U$ and $t_"On"$ denote the time from the beginning of the sleep period to the next @ul packet arrival or On duration, respectively.
The first of these two events ends the sleep period, yielding

$
t_s = min(t_P_U, t_"On")
$

To compute the expectation of $t_s$, the distributions of $t_P_U$ and $t_"On"$ both need to be known.
Due to the Poisson distribution of @ul traffic, the distribution of $t_P_U$ is known to be exponential, depending on the mean @ul inter-arrival time $T_P_U$:

$
t_P_U tilde.op italic("Exp")(T_P_U)
$

However, the distribution of $t_"On"$ directly depends on the distribution of the moment a sleep period begins within the @drx cycle.
Due to the buffering of @dl traffic at the @bs, the moment in which a sleep period begins is not uniformly distributed throughout the @drx cycle.
Specifically, it is impacted by the duration of the previous sleep period which affects the probability for buffered @dl traffic to be transmitted at the beginning of the On duration, therefore introducing recursion.
To break this recursion, the beginning of a sleep period might be assumed to be uniformly distributed throughout the @drx cycle.
Yet, depending on the input parameters, this may introduce a significant error.
While there may be methods to handle the recursive dependency, the complexity of a potential solution is likely out of the scope of this thesis.
Therefore, the expectation-based approach of this section is not further explored.


== Probability-Based Approach

An alternative approach derives $r_"sleep"$ via the expected active time _per @drx cycle_.
This, in turn, can be determined by deriving the probability for the @ue to be active at a given point of time in the @drx cycle and integrating that probability over each point of time in the cycle
#footnote[
  This idea was brought up by Prof. Dr. Richthammer at the Stochastics Working Group of the Math Department at Paderborn University -- thank you, Mr. Richthammer!
].
Specifically, consider a @drx cycle of length $T_C$.
Let $A = limits(union)_i A_i$ be the conjunction of random intervals $A_i subset.eq [0,T_C]$ during which the @ue is in @drx active state, i.e., $A$ is a set of time points.
Define the length of $A$ as $|A|$.
Futher, let $1_A (x)$ be the indicator function of $A$:

$
1_A (x) := cases(0 "if" x in.not A, 1 "if" x in A)
$

Then it holds that

$
|A| = integral_0^T_C 1_A(x) d x
$

Using the properties of expectation and Fubini's theorem @durrettProbability2019 (given that $|A|$ is non-negative), the expected active time within a @drx cycle can therefore be written as

$
EE[ |A| ] = integral_0^T_C EE[1_A (x)] d x = integral_0^T_C PP(x in A) d x
$

$PP(x in A)$ denotes the probability that the @ue is active at a given time $x in [0,T_C]$.
During the On duration, i.e., $x in [0,T_"On"]$, the @ue is always active ($PP(x in A) = 1$).
At any other time $x in (T_"On",T_C]$, the probability $PP(x in A)$ depends on the events prior to $x$.
More precisely, the @ue is active at time $x$ if and only if it has woken up at some time in the past and has been kept awake by traffic since then.
This observation reduces the derivation of $PP(x in A)$ to a subproblem which is examined in more detail below.

Consider a time interval $T = [0, t]$, where the inactivity timer has been reset at time zero.
We are looking for the probability that the @ue remains active during $T$, i.e., the inactivity timer never expires within $T$.
This is the case if and only if there is no duration of length $T_I$ within T in which no packet arrives.
To derive this probability, we will condition the number of arrivals in $T$ to a fixed $N in NN$ and apply the law of total probability, i.e., sum up the conditional probabilities over all $N$, weighted with the marginal probability of each~$N$.

Conditioning on a number $N$ of arrivals within $T$, define the arrival times as $X_1, X_2, dots, X_N$ and the durations between arrivals as $t_1, t_2, dots, t_(N+1)$, as illustrated in @figDrxTimerExpiryProb.
Note that $t_1 = X_1$ represents the time from the left limit of $T$ to the first arrival $X_1$ and $t_(N+1) = t - X_N$ measures the time from the last arrival $X_N$ to the right limit of~$T$.

#include "./figures/drx-timer-expiry-prob.typ"

Because the number of arrivals during $T$ is conditioned to $N$ and arrivals are modeled as a Poisson process, the arrival times $X_i$ are independent of each other and uniformly distributed over $T$.
Per definition, the values of $X_i$ are ordered increasingly.
Therefore, $X_i$ is the $i$#nobreak()th order statistic of a set of $N$ @iid random variables.
Order statistics of uniform @iid random variables are Beta-distributed with known parameters:

$
X_i/t tilde.op italic("Beta")(i, N-i+1)
$

For the first inter-arrival time $t_1$, this translates to $t_1/t = X_1/t tilde.op italic("Beta")(1, N)$.
Intuitively, all scaled $t_i$ are expected to follow the same distribution as $t_1$, although they are constrained to sum up to one and thus cannot be independent.
It is a proven fact~@qiDirichlet2021 that the scaled @iat:pl in this situation follow a flat $italic("Dirichlet"({1,...,1}, N+1))$ distribution, which is a multivariate generalization of the Beta distribution.
This confirms that each $t_i$ is $italic("Beta")(1, N)$#nobreak()-#nobreak()distributed.
Given values for each scaled inter-arrival time (where all @iat:pl sum up to one), the probability density function of the flat Dirichlet distribution serves as the joint density function for all @iat:pl.

The probability of interest can be expressed as $PP(max{t_1,dots,t_(N+1)} <= T_I)$.
Deriving the exact probability requires integrating over the Dirichlet distribution's density function for all combinations of $t_i$ that satisfy the sum constraint and have at least one $t_i > T_I$.
An analytical solution to this is complex and out of the scope of this thesis, considering that the problem at hand is only a subproblem, the solution of which itself needs to be summed up over $N$ and integrated in a later step.
Instead, in the following paragraphs, a simple approximation will be explored and evaluated by comparing it to a Monte Carlo simulation.
For the approximation, assume that $t_i$ are independent.
Then the probability that no @iat exceeds $I_T$ can be decomposed into the product of probabilities that each individual @iat does not exceed $I_T$, which is the cummulative distribution function of the $italic("Beta")(1, N)$ distribution, defined as $I_x (1, N) = 1 - (1-x)^N$.

$
PP(max{t_1,dots,t_(N+1)} <= T_I)
&= PP(t_1,dots,t_(N+1) <= T_I) \
&approx product_(i=1)^(N+1) PP(t_i <= T_I) \
&= I_(T_I/t) (1, N)^(N+1) = (1 - (1-T_i/t)^N)^(N+1)
$ <equation-ti-max-approximation>

@figDirichletMonteCarlo compares the approximation from @equation-ti-max-approximation with Monte Carlo simulation results from $3 times 10^5$ random samples drawn from a flat Dirichlet distribution.
It can be observed that the error term is comparably large for small $N$ and gradually decreases for larger values of $N$, while taking a normal-distribution-like shape.
Given that the approximation error is introduced by assuming independence of @iat:pl, this can be explained by the law of large numbers.
Specifically, with increasing $N$, the probability decreases that the sum of independently sampled @iat:pl defers from its expectation ($t$), i.e., the @iat:pl don't add up to $t$, introducing an error.

#include "./figures/dirichlet-monte-carlo.typ"

With an approximation of $PP(max{t_1,dots,t_(N+1)} <= T_I)$ obtained for a fixed $N$, the approximated probabilities can now be summed up for all $N=n$, weighted by the Poisson probability of $N=n$ packet arrivals during $t$.

$
PP(quote.l.double"No" &"timer expiry in time" t quote.r.double)
= sum_(n=1)^oo PP(cal(N) (t) = n) PP(max{t_1,dots,t_(N+1)} <= T_I | N = n) \
&= sum_(n=1)^oo (lambda^n e^(-lambda))/n!  (1 - (1-T_I/t)^n)^(n+1)
= e^(-lambda) sum_(n=1)^oo (lambda^n)/n!  (1 - (1-T_I/t)^n)^(n+1)
$

Although the summation includes an exponential series, the series cannot easily be brought into a closed form because it is weighted with another exponential term which depends on $n+1$.
Due to the lack of a closed form representation, it becomes evident that the resulting probabilities for the considered subproblem -- despite already involving an approximation -- are hard to compute, therefore defeating the purpose of an analytical solution.

// Goodbye, math – it was fun though.
