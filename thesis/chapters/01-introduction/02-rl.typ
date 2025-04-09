#import "@preview/glossarium:0.5.3": gls

== Reinforcement Learning <secRlIntro>

The previous section has provided an introduction to 5G @nr, detailing the relevant concepts and mechanisms built upon in this thesis.
Similarly, this section introduces #gls("rl", long: true).
While @rl has evolved into a broad field of research over the past decades @suttonBartoRl2020, the foundations required for its application in this thesis can be summarized much more concisely than is the case with 5G @nr.

@rl is a field of Machine Learning in which an agent learns to solve a task by interacting with an environment @suttonBartoRl2020.
More specifically, as illustrated in @figRlLoop, an @rl agent repeatedly selects an action from a provided action space and communicates it to the environment.
For each action taken, the agent receives an observation of the environment's state, as well as a numeric reward signal.
The goal of the agent is to choose its actions in such a way that the reward signal is maximized @suttonBartoRl2020.

#include "./figures/rl-loop.typ"

Unlike supervised learning, where a training data set, i.e., a set of example data labelled by an expert, is used to classify unlabeled data, @rl does not require an expert-labelled training data set @suttonBartoRl2020.
Instead, an @rl agent learns to predict reward-maximizing actions by exploring the effects of its actions on the environment.
In a sense, the agent learns from its own experience.
This also implies that, in order to estimate which actions yield a high reward, the agent needs to explore various actions, including those that may make it fail at its task.
This issue is commonly referred to as the "trade-off between exploration and exploitation" @suttonBartoRl2020, where exploration means trying potentially suboptimal actions, and exploitation refers to applying actions that are expected to yield a high reward.
As there is no universal solution to this trade-off, many @rl algorithms, i.e., @rl agent implementations, provide parameters ("hyperparemeters") to make the exploration behavior configurable for individual tasks @schulmanPPO2017 @suttonBartoRl2020.

An important consideration for the application of @rl is the choice of environment.
Depending on the environment's domain, interactions with a real-world environment may take considerable amounts of time, or even cause damage in case of improper actions.
An alternative to training @rl agents on real-world environments is the use of a computer simulation.
This approach can both reduce the wall-clock time required for training (if the simulation operates faster than the real system), and it can avoid causing damage to a real-world environment. 
Moreover, computer simulation allows to prototype @rl solutions when a real environment is not easily available -- as is the case with the cellular handover environment in this thesis.

While a deep understanding of @rl algorithms can be helpful, it is not a necessary requirement for applying state-of-the-art @rl algorithms.
Therefore, this section does not provide a detailed introduction to specific algorithms.
However, a few more definitions are relevant for the practical application of @rl in this thesis, which will be presented in the following.

- *Policy*:
  The @rl agent's behavior is defined by a policy, representing the decision making that was learned while interacting with the environment @suttonBartoRl2020.
  Applying the agent's policy to an observation yields the agent's next action.  
- *Value Function*:
  A value function is learned internally by the @rl agent to estimate how desirable a given environment state is over the long term @suttonBartoRl2020.
  For instance, taking a specific action in one step might result in a high one-time reward, yet leave the system in a state that makes high future rewards unlikely.
  A value function prevents this by enabling an @rl agent to "plan ahead" and favor actions that promise higher rewards in the long run @suttonBartoRl2020.
- *Reward Function*:
  The reward function maps the environment's state at a given time to a numeric reward signal for the @rl agent.
  It plays a central role in guiding the agent to optimally solve the task.
  Its design is crucial for the performance of an @rl agent and involves knowledge about the agent's goal @eschmannRewardFunctionDesign2021.
  Choosing an inappropriate reward function can make an agent learn a policy that does not solve the given task, despite maximizing the reward signal.
  This behavior is also known as "reward hacking" @yuanRewardHacking2019.
- *Episodic and Continuing Tasks*:
  Many tasks -- such as playing a game -- naturally end after a certain event.
  These tasks are referred to as _episodic_ tasks, as they divide into distinct, independent episodes (e.g., multiple rounds of a game) @suttonBartoRl2020.
  By contrast, _continuing_ tasks may continue infinitely @suttonBartoRl2020.
  Controlling handovers in a @ran does not exhibit a natural end and is therefore a continuing task.  
  For practical reasons, when training @rl agents on continuing tasks, the concept of episodes is typically emulated by truncating the task after a set amount of steps @suttonBartoRl2020.

A key advantage of applying @rl to the handover optimization problem is that, given a target metric -- which is @ue @qoe in this thesis -- the optimization problem for this metric does not have to be solved explicitly, as required for static, domain-specific algorithms.
Instead, an @rl algorithm dynamically determines a policy to optimize the provided metric.
In a complex environment, this policy may exploit environment dynamics that might otherwise remain unnoticed in the process of designing domain-specific algorithms.
