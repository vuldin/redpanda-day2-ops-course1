We can now continue upgrading the remaining brokers (`redpanda-0`, and `redpanda-1`), and we'll continue in reverse order with `redpanda1`.

> Note: While the commands below are provided, the details of what each command does is not included.  Instead you can find these details on the previous section where we walked through all same commands for `redpanda-2`. Copy and paste each command into the terminal to the left and run them separately.

Here are the commands to follow in order for `redpanda-1`:

```
rpk cluster health
rpk cluster maintenance enable 1 --wait
rpk cluster maintenance status
rpk cluster health
./stop-broker.sh redpanda-1
./update-version.sh redpanda-1 v23.2.5
docker-compose -p 2-rolling-upgrade -f compose.redpanda-1.yaml up -d
rpk redpanda admin brokers list
rpk cluster maintenance disable 1
rpk cluster maintenance status
```

And here are the commands for `redpanda-0`:

```
rpk cluster health
rpk cluster maintenance enable 0 --wait
rpk cluster maintenance status
rpk cluster health
./stop-broker.sh redpanda-0
./update-version.sh redpanda-0 v23.2.5
docker-compose -p 2-rolling-upgrade -f compose.redpanda-0.yaml up -d
rpk redpanda admin brokers list
rpk cluster maintenance disable 0
rpk cluster maintenance status
```

Finally, you can verify that all brokers are upgraded to `v23.2.5`:

```
rpk redpanda admin brokers list
```{{exec}}

