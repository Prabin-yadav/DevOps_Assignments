# Basic Containerization (Docker) & Jenkins Freestyle Project

## Objective
This assignment demonstrates how to package a simple Python Flask application into a Docker container, and how to set up a Jenkins Freestyle project that pulls the same application from a Git repository and verifies the workspace contents through a build step.

---

## What is Docker
Docker is a container platform used to package applications together with all their dependencies into lightweight, portable units called **containers**. Because a container bundles the application, its runtime, and its libraries together, it behaves the same way regardless of the machine it runs on — this solves the classic "it works on my machine" problem.

## Containerization Concept
Containerization separates the application from the underlying host system. Instead of installing Python, Flask, and other dependencies directly on the host machine, everything the application needs is defined once inside a **Dockerfile** and baked into an **image**. That image can then be run as a container on any machine that has Docker installed, without needing to manually install or configure anything else.

## Docker Architecture
Docker is built around four core pieces:

- **Docker client** – the command-line tool (`docker`) used to issue commands such as `build` and `run`.
- **Docker daemon** – the background service that actually builds images and runs containers.
- **Images** – read-only templates that define what should be inside a container (base OS, dependencies, application code, startup command).
- **Containers** – running instances of an image. Multiple containers can be started from the same image.

## Flask Application Overview
The application is a minimal Flask web server that returns a plain text response from the root (`/`) route and listens on port `5000`.

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
	return "Hello from Main and Feature Branch!"

if __name__ == "__main__":
	app.run(host="0.0.0.0", port=5000, debug=True)
```

`host="0.0.0.0"` is important inside a container — it tells Flask to accept connections from outside the container, not just from `localhost` within the container itself.

---

## Task 3.1: Dockerfile, Image Build & Container Run (1.5 Marks)

### Step 1 — Write the Dockerfile
A Dockerfile was created in the project directory alongside `app.py`. It defines how the image is built, layer by layer.

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir Flask

EXPOSE 5000

CMD ["python", "app.py"]
```

**Line-by-line explanation:**

- `FROM python:3.11-slim` — starts the image from an official, minimal Python 3.11 base image. The `slim` variant keeps the image size small by excluding unnecessary OS packages.
- `WORKDIR /app` — sets `/app` as the working directory inside the container. All subsequent instructions (`COPY`, `RUN`, `CMD`) run relative to this directory.
- `COPY . .` — copies everything from the build context (the project folder on the host) into `/app` inside the image, including `app.py`.
- `RUN pip install --no-cache-dir Flask` — installs the Flask dependency inside the image at build time. `--no-cache-dir` avoids storing pip's download cache, keeping the image smaller.
- `EXPOSE 5000` — documents that the container listens on port 5000. This is informational; it does not publish the port by itself.
- `CMD ["python", "app.py"]` — the default command executed when a container is started from this image; it launches the Flask application.

**Screenshot — Dockerfile**
The Dockerfile above, open and edited in Visual Studio Code, confirming the exact contents used to build the image.

![Dockerfile in VS Code](<screenshots/Screenshot 2026-07-27 130946.png>)

### Step 2 — Build the Docker Image
From the project directory (the same folder containing the Dockerfile and `app.py`), the image was built with:

```bash
docker build -t flask-hello .
```

- `-t flask-hello` tags the resulting image with the name `flask-hello` so it can be referenced easily later.
- `.` tells Docker to use the current directory as the build context (the set of files Docker can `COPY` into the image).

Once built, `docker images` was run to confirm the image now exists locally.

**Screenshot — Build output and image list**
Shows the build completing all steps successfully ("Building 19.6s (10/10) FINISHED" — pulling the base image, copying the build context, installing Flask, and exporting the final image). The following `docker images` output confirms `flask-hello:latest` is now present in the local image list, alongside other unrelated images already on the machine (`jenkins/jenkins:lts`, `hello-world`, `n8nio/n8n`).

![Docker build output and image list](<screenshots/Screenshot 2026-07-27 131216.png>)

### Step 3 — Run the Container
The image was run as a container with port mapping so it could be reached from the host machine's browser:

```bash
docker run -d -p 5000:5000 --name flask-container flask-hello
```

- `-d` runs the container in detached (background) mode.
- `-p 5000:5000` maps port 5000 on the host to port 5000 inside the container (the port Flask listens on).
- `--name flask-container` gives the container a readable name instead of a random one.
- `flask-hello` is the image the container is created from.

To confirm the container was actually running, `docker ps` was used:

```bash
docker ps
```

**Screenshot — `docker ps` output**
Shows the running container: container ID `040df6de9b5c`, image `flask-hello`, command `"python app.py"`, status `Up 8 seconds`, ports `0.0.0.0:5000->5000/tcp`, and name `flask-container`.

![docker ps output](<screenshots/Screenshot 2026-07-27 131306.png>)

### Step 4 — Verify in the Browser
With the container running and the port mapped, the application was accessed directly from a web browser.

**Screenshot — Application in browser**
Shows `localhost:5000` in the browser displaying the response **"Hello from Main and Feature Branch!"**, confirming the containerized Flask app is reachable from the host.

![Flask app in browser](<screenshots/Screenshot 2026-07-27 131741.png>)

### Step 5 — Verify in Docker Desktop
As a final check, Docker Desktop's GUI was used to confirm the container's running state visually.

**Screenshot — Docker Desktop containers view**
Shows the Containers list in Docker Desktop, with `flask-container` (image `flask-hello`, port `5000:5000`) shown as running, alongside a separately running `jenkins` container used for Task 3.2.

![Docker Desktop container view](<screenshots/Screenshot 2026-07-27 131803.png>)

---

## Task 3.2: Jenkins Freestyle Project (1.5 Marks)

### Jenkins Introduction
Jenkins is an automation server used to build continuous integration and continuous delivery (CI/CD) pipelines. A **Freestyle project** is the simplest job type in Jenkins — it checks out source code from a single SCM (source control) repository and then runs a sequence of build steps, such as shell commands. It's a good starting point for demonstrating basic checkout-and-verify workflows before moving to more advanced Pipeline jobs.

### Step 1 — Add GitHub Credentials
Before Jenkins can pull a repository, it needs a way to authenticate with GitHub. A GitHub Personal Access Token (PAT) was added to Jenkins as a credential so the job could securely check out the repository without exposing the token in plain text anywhere in the job configuration.

**Screenshot — Jenkins credentials**
Shows **Manage Jenkins → Credentials**, with a credential named `github-pat` (username `prabin`, token hidden) stored under the System / Global credentials domain.

![Jenkins credentials](<screenshots/Screenshot 2026-07-24 153928.png>)

### Step 2 — Create the Freestyle Project
A new Jenkins item was created and configured as a Freestyle project.

**Screenshot — New Item creation**
Shows the **New Item** screen with the item name `Git_Practice` entered and **Freestyle project** selected as the job type (as opposed to Pipeline or other job types).

![New Freestyle item](<screenshots/Screenshot 2026-07-24 154213.png>)

### Step 3 — Configure Source Code Management
In the job configuration, the **Source Code Management** section was set to pull from the Git repository created in Task 1.1.

- **Repository URL:** `https://github.com/Prabin-yadav/practice1.git`
- **Credentials:** `prabin/****** (github-pat)` — the credential created in Step 1
- **Branch Specifier:** `*/main`

**Screenshot — Source Code Management configuration**
Shows the SCM section filled in with the repository URL, the selected `github-pat` credential, and the branch specifier `*/main`.

![Jenkins SCM configuration](<screenshots/Screenshot 2026-07-24 154229.png>)

### Step 4 — Configure the Build Step
Under **Build Steps**, an **Execute shell** step was added. This step runs after Jenkins has checked out the repository into the job's workspace, and it prints information about the build and the checked-out files.

```bash
echo ""
echo "BUILDING: ${JOB_NAME}, BUILD #${BUILD_NUMBER}"
echo "Workspace: ${WORKSPACE}"
echo ""
echo "Listing files checked out from Git:"
ls -la
echo ""
echo "Contents of app.py:"
cat app.py
echo ""
echo "Hello Jenkins!"
```

- `${JOB_NAME}` and `${BUILD_NUMBER}` are Jenkins environment variables that identify the current job and build number.
- `${WORKSPACE}` prints the path where Jenkins checked out the repository for this build.
- `ls -la` lists all files (including hidden ones) in the workspace, proving the repository was actually checked out.
- `cat app.py` prints the contents of the Flask application file, confirming the correct source file is present.
- The final `echo "Hello Jenkins!"` is a simple marker used to confirm the shell step ran to completion.

**Screenshot — Build step configuration**
Shows the **Execute shell** build step with the command block above entered in the job configuration.

![Jenkins build step configuration](<screenshots/Screenshot 2026-07-24 154238.png>)

### Step 5 — Trigger the Build
The job was saved and triggered manually using **Build Now**.

**Screenshot — Job status page**
Shows the `Git-Practice` project status page after the build finished, with build **#7** marked successful (green check) and listed as the last build, last stable build, and last successful build.

![Jenkins job status](<screenshots/Screenshot 2026-07-24 154257.png>)

### Step 6 — Review the Console Output
The console output for build #7 was opened to verify each stage of the build.

**Screenshot — Console output (checkout stage)**
Shows Jenkins authenticating with the `github-pat` credential, fetching from `https://github.com/Prabin-yadav/practice1.git`, and checking out revision `446518be3d48f3f16cc631390eaa800f9ede07eb` on `refs/remotes/origin/main`. Immediately after checkout, the shell script begins executing, starting with the `BUILDING` and `Workspace` echo lines.

![Jenkins console output - checkout](<screenshots/Screenshot 2026-07-24 154320.png>)

**Screenshot — Console output (workspace listing and result)**
Shows the rest of the console output: the contents of `app.py` printed via `cat app.py` (matching the Flask application source shown earlier), followed by the `Hello Jenkins!` message and the final status line **`Finished: SUCCESS`**, confirming the build completed without errors.

![Jenkins console output - success](<screenshots/Screenshot 2026-07-24 154328.png>)

---

## Learning Outcomes
After completing this assignment, I learned how to:

- write a Dockerfile that builds a minimal, working image for a Flask application
- build a Docker image locally and inspect it with `docker images`
- run a container in detached mode and map a container port to a host port
- verify a running container both from the command line (`docker ps`) and visually through Docker Desktop
- securely store and use Git credentials (a GitHub PAT) inside Jenkins
- configure a Jenkins Freestyle project's Source Code Management section to check out a specific branch of a GitHub repository
- add an Execute Shell build step to inspect a Jenkins workspace and verify checked-out files
- read and interpret Jenkins console output to confirm a successful build

## Technologies Used
- Python 3
- Flask
- Docker
- Jenkins (Freestyle project)
- Git / GitHub (with Personal Access Token authentication)

## Author
Prabin Yadav