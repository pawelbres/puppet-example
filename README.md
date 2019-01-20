==== All you need to do: ====

1. `vagrant up`
2. `cd elk/kibana && docker build -t elastic/kibana:6.5.4-wazuh_3.8 . && cd ../..`
3. `cd elk && docker-compose up -d`
4. Run 'till you see `opened`: `echo "nc -z 192.168.41.11 55000 && echo 'opened' || echo 'closed'" > ./tmp.checker.sh && watch -n 5 sh ./tmp.checker.sh`
5. open in your browser "http://127.0.0.1:8080/app/wazuh" and configure your wazuh manager: with `foo:bar@http://192.168.41.11:55000`
6. it should be working now - make some operations on the edge-node1 and check if they are visible in the kibana
