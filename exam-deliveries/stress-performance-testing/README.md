# Stress Performance Testing - Apache JMeter

Using Apache JMeter for the following stress performance tests.

## Configuration

All stress test are configured to use this `GET` request for the deployed Munchora server.

![Jmeter GET recipes](assets/jmeter-get-recipes.png)

Same assertions for the three different tests.

![Jmeter assertions](assets/jmeter-assertions.png)

- `200` &rarr; status OK
- `302` &rarr; Ruby on Rails rate limit has been exceeded - client gets redirected to https://disney.com
- `503` &rarr; Rate limit configured at Reverse Proxy Nginx.

---

<br>

## Stress Testing

Push system beyond normal limits to find breaking points -
makes use of extension `pg@gc - Stepping Thread Group`.

![Stepping Stress test jmeter](assets/jmeter-stepping-stress-test.png)

**Aggregated results:**

![Jmeter aggregated results](assets/jmeter-stepping-stress-aggregated-result.png)

---

## Load testing

Verify system performance under expected normal-to-peak load (the implementation is expecting
middle input)

| Thread group setting | Value      | Rationale                      |
|----------------------|------------|--------------------------------|
| Number of Threads    | 200        | Expected peak concurrent users |
| Ramp-up Period       | 20 seconds | Smooth, gradual increase       |
| Loop Count           | 5          | Enough to gather statistics    |

**Aggregated results:**

![Load test result](assets/jmeter-load-testing-aggregated-results.png)

---

## Spike testing

Verify system performance under a suddenly huge amount of traffic towards server.

| Thread group setting | Value                | Rationale                             |
|----------------------|----------------------|---------------------------------------|
| Number of Threads    | 1000 (A huge number) | Simulates the peak of the surge       |
| Ramp-up Period       | 0 seconds            | Very short to simulate a sudden spike |
| Loop Count           | 10                   | Load hits once and immediately stops  |

**Aggregated results:**

![Jmeter aggregated results](assets/jmeter-spike-test-aggregated-results.png)

---

Test system response to sudden, massive traffic increases.

```bash
# Ensure to be positioned at ./stress-performance-testing/
# run stress tests
jmeter -n -t stepping_thread_group_stress_test.jmx -l results/load_results.jtl -e -o reports/load_test

# run load tests
jmeter -n -t load_test.jmx -l results/load_results.jtl -e -o reports/load_test

# run spike tests
jmeter -n -t spike_test.jmx -l results/load_results.jtl -e -o reports/load_test
```
