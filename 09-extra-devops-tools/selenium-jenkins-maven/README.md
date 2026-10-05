# Jenkins + Maven + Selenium/JUnit (Syllabus Experiments 3, 4, 5)

Goal: automate Java/Web application testing inside the Jenkins pipeline, using Maven to run Selenium or JUnit test cases.

## 1. Install Maven

Official guide: https://maven.apache.org/install.html

- **Ubuntu/Linux:**
  ```bash
  ec2$ sudo apt install maven -y
  ```
- **macOS:**
  ```bash
  local$ brew install maven
  ```
- **Windows:** download the binary zip from https://maven.apache.org/download.cgi, extract, add `bin/` to PATH (steps detailed on the official install guide above).

Verify:
```bash
mvn -version
```

## 2. JUnit

Official docs: https://junit.org/junit5/docs/current/user-guide/ — JUnit is pulled in as a Maven **dependency** (`pom.xml`), not installed system-wide:

```xml
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter</artifactId>
    <version>5.10.2</version>
    <scope>test</scope>
</dependency>
```

## 3. Selenium

Official docs: https://www.selenium.dev/documentation/webdriver/getting_started/ — also added as a Maven dependency:

```xml
<dependency>
    <groupId>org.seleniumhq.selenium</groupId>
    <artifactId>selenium-java</artifactId>
    <version>4.21.0</version>
</dependency>
```

Selenium needs a browser + matching driver on the Jenkins agent. Easiest for a headless EC2 instance:

```bash
ec2$ sudo apt install chromium-browser chromium-chromedriver -y
```
(Selenium Manager, bundled with modern Selenium Java, can also auto-download the right driver — see https://www.selenium.dev/documentation/selenium_manager/)

## 4. Project layout

A standard Maven project (`pom.xml` + `src/main/java` + `src/test/java`) is the expected input here. Create one with:

```bash
mvn archetype:generate -DgroupId=com.sakec.devsecops -DartifactId=sample-webapp-tests \
  -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
```

Add JUnit/Selenium dependencies to the generated `pom.xml`, then write tests under `src/test/java` (e.g., a Selenium test that opens `http://<EC2_PUBLIC_IP>:5000` and asserts the page title/content from [`03-sample-app-deployment-ec2`](../../03-sample-app-deployment-ec2/)).

## 5. Run tests locally

```bash
mvn test
```

## 6. Wire into Jenkins

1. Install the **Maven Integration** plugin.
2. Manage Jenkins → Tools → add a Maven installation (or let Jenkins auto-install it).
3. Add a stage to the Jenkinsfile (alongside the Docker stages from [`05-jenkins-cicd/Jenkinsfile`](../../05-jenkins-cicd/Jenkinsfile)):

```groovy
stage('Test - Maven/Selenium/JUnit') {
    steps {
        dir('path/to/sample-webapp-tests') {
            sh 'mvn -B test'
        }
    }
    post {
        always {
            junit 'path/to/sample-webapp-tests/target/surefire-reports/*.xml'
        }
    }
}
```

The `junit` step publishes test results in Jenkins' build UI (pass/fail counts, trends over builds) — install the **JUnit** plugin if not already present.

## Teaching point

This stage should run **before** `Deploy` in the pipeline — the DevSecOps principle of "don't ship what fails its tests," same spirit as the security gates in Day 6.
