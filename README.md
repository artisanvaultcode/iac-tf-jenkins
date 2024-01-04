# Deploying Jenkins Master and Worker Instances

-- updates !  - java-17-amazon-corretto-devel 

# Credits
-- Moosa Khalid | ACG Course
-----Deploying to AWS with Terraform and Ansible

# Issues:

-- ansible-playbooks is deprecated in linux 2023
-- do not have any idea how to reproduce https://github.com/linuxacademy/content-terraform-jenkins.git  **"jenkins 4 years old"**
-- when executing the validation if the jenkins is running 
```shell
    - name: Wait until Jenkins is up
      shell: result_first=1; while [[ $result_first != 0 ]]; do if [[ `grep 'Jenkins is fully up and running' /var/log/jenkins/jenkins.log` ]];then result_first=0;else sleep 4;fi;done
      register: result
      until: result.rc == 0
```
-----> **the directory /var/log/jenkins and the file jenkins.log does not exist**

-- worker can be created because of this error:

```html
aws_instance.jenkins-worker-oregon[0] (local-exec): fatal: [18.118.206.27]: FAILED! => {"changed": true, "cmd": "cat /home/ec2-user/creds.xml | java -jar /home/ec2-user/jenkins-cli.jar -auth @/home/ec2-user/jenkins_auth -s http://10.0.1.243:8080 create-credentials-by-xml system::system::jenkins _", "delta": "0:00:00.737150", "end": "2024-01-04 17:28:20.074684", "msg": "non-zero return code", "rc": 255, "start": "2024-01-04 17:28:19.337534", "stderr": "io.jenkins.cli.shaded.jakarta.websocket.DeploymentException: Handshake error.\n\tat io.jenkins.cli.shaded.org.glassfish.tyrus.client.ClientManager$3$1.run(ClientManager.java:658)\n\tat io.jenkins.cli.shaded.org.glassfish.tyrus.client.ClientManager$3.run(ClientManager.java:696)\n\tat java.base/java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:539)\n\tat java.base/java.util.concurrent.FutureTask.run(FutureTask.java:264)\n\tat io.jenkins.cli.shaded.org.glassfish.tyrus.client.ClientManager$SameThreadExecutorService.execute(ClientManager.java:849)\n\tat java.base/java.util.concurrent.AbstractExecutorService.submit(AbstractExecutorService.java:123)\n\tat io
```

**-- ansible-playbook has been deprecated only aws linux 2 ami's provide those extensions**