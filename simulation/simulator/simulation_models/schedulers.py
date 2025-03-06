from simulator.environment.core.schedulers import Scheduler


class AppAwareResourceFairScheduler(Scheduler):
    """
    Like `ResourceFair`, but does not assign more resources than required to app-aware
    UEs with definite desired data rates
    """

    def update_data_rates(self, bs, connections):
        if len(connections) == 0:
            # So we don't devide by 0 below
            return

        # Sort connections by desired resources
        connections = sorted(
            connections,
            key=lambda c: c.ue.desired_data_rate / c.maximal_data_rate,
        )

        share_per_remaining_ue = 1 / len(connections)

        for scheduled_ues, connection in enumerate(connections):
            desired_data_rate = connection.ue.desired_data_rate
            maximal_share_data_rate = (
                connection.maximal_data_rate * share_per_remaining_ue
            )

            if desired_data_rate > maximal_share_data_rate:
                # The UE takes its full share
                connection.current_data_rate = maximal_share_data_rate
            else:
                # The UE takes only what it needs and leaves the rest of its share for
                # the remaining UEs
                connection.current_data_rate = desired_data_rate
                allocated_share_portion = desired_data_rate / maximal_share_data_rate
                remaining_ues = len(connections) - scheduled_ues - 1

                if remaining_ues > 0:
                    share_per_remaining_ue += (
                        share_per_remaining_ue
                        * (1 - allocated_share_portion)
                        / remaining_ues
                    )
