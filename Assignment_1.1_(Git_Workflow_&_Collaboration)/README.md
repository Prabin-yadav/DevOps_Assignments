# Git Workflow & Collaboration Assignment

## Objective
This assignment demonstrates the basic Git workflow used in collaborative software development. It covers repository initialization, feature branching, remote pushing, merge conflict creation, and manual conflict resolution using a small Python Flask application.

## Introduction to Git
Git is a distributed version control system used to track changes in source code. It helps developers work on the same project safely by separating new work into branches, preserving history through commits, and allowing changes to be merged only after review or conflict resolution.

## Application Overview
The project uses a minimal Flask application that returns a plain text response from the root route. The code was changed on both `main` and `feature/user-auth` to simulate a merge conflict and show how Git handles conflicting edits.

The final application code is:

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
	return "Hello from Main and Feature Branch!"

if __name__ == "__main__":
	app.run(host="0.0.0.0", port=5000, debug=True)
```

## Git Repository Initialization
The first step was to initialize the repository, add the Flask app, and create the first commit on the main branch.

Commands used:

```bash
git init
git add .
git commit -m "Initial Flask Hello World application"
```

Explanation of commands:

`git init` creates a new Git repository in the current folder.

`git add .` stages all files in the working directory.

`git commit -m "Initial Flask Hello World application"` saves the staged files as the first snapshot in Git history.

### Screenshot
The screenshot below shows the initial repository setup and the first commit.

![Initial Git repository setup](screenshots/Screenshot%202026-07-13%20132330.png)

## Git Branch Creation
After the base version was committed, a separate feature branch named `feature/user-auth` was created so that the new change could be developed independently.

Commands used:

```bash
git checkout -b feature/user-auth
git branch
```

Explanation of commands:

`git checkout -b feature/user-auth` creates a new branch and switches to it immediately.

`git branch` lists all local branches and marks the active one with an asterisk.

### Screenshot
This screenshot shows the feature branch being created and selected.

![Feature branch creation](screenshots/Screenshot%202026-07-13%20132345.png)

## Feature Branch Workflow
The Flask response text was modified on the feature branch. This simulates a small functional change that might be developed before merging back into `main`.

Commands used:

```bash
git add .
git commit -m "Modified homepage in feature branch"
git push -u origin feature/user-auth
```

Explanation of commands:

`git add .` stages the modified file.

`git commit -m "Modified homepage in feature branch"` creates a commit containing the feature update.

`git push -u origin feature/user-auth` uploads the branch to GitHub and sets upstream tracking.

### Screenshots

#### Commit on Feature Branch
This screenshot shows the feature branch commit after editing the response text.

![Feature branch commit](screenshots/Screenshot%202026-07-13%20132522.png)

#### Branch Pushed to GitHub
This screenshot shows the successful push of the feature branch to the remote repository.

![Feature branch pushed](screenshots/Screenshot%202026-07-13%20132849.png)

## Merge Conflict Simulation
To simulate a real-world conflict, the same line in `app.py` was changed again on the `main` branch and then merged with the feature branch.

Commands used:

```bash
git checkout main
git add .
git commit -m "Modified homepage on main branch"
git merge feature/user-auth
```

Explanation of commands:

`git checkout main` switches back to the main branch.

`git add .` stages the change made on `main`.

`git commit -m "Modified homepage on main branch"` stores that change in Git history.

`git merge feature/user-auth` tries to combine the feature branch into `main`.

Git detected that both branches changed the same line in `app.py`, so it stopped and reported a merge conflict.

### Screenshots

#### Changes on Main Branch
This screenshot shows the updated `main` branch version that conflicted with the feature branch.

![Main branch change](screenshots/Screenshot%202026-07-13%20132906.png)

#### Merge Conflict
This screenshot shows the merge conflict message and the conflict markers inside `app.py`.

![Merge conflict in app.py](screenshots/Screenshot%202026-07-13%20134302.png)

## Conflict Resolution
The conflict was resolved manually by editing `app.py` and choosing the final response text to keep. After saving the resolved file, the merge result was committed and pushed.

Commands used:

```bash
git add .
git commit -m "Resolved merge conflict"
git push
```

Explanation of commands:

`git add .` stages the conflict-free file after manual editing.

`git commit -m "Resolved merge conflict"` records the final merged version.

`git push` uploads the updated main branch to the remote repository.

### Screenshots

#### Conflict Resolved
This screenshot shows the resolved file after removing the conflict markers and keeping the final response.

![Conflict resolved](screenshots/Screenshot%202026-07-13%20134331.png)

#### Updated Main Branch
This screenshot shows the final pushed state of the `main` branch on GitHub.

![Updated main branch](screenshots/Screenshot%202026-07-13%20134346.png)

## Git Commands Used
```bash
git init
git checkout -b feature/user-auth
git branch
git add .
git commit -m "Initial Flask Hello World application"
git commit -m "Modified homepage in feature branch"
git push -u origin feature/user-auth
git checkout main
git merge feature/user-auth
git commit -m "Resolved merge conflict"
git push
```

## Learning Outcomes
After completing this assignment, I learned how to:

- initialize a Git repository from scratch
- create and work with feature branches
- push a branch to a remote GitHub repository
- create and resolve a merge conflict manually
- document Git workflow with screenshots and command evidence

## Project Structure
```text
.
├── app.py
├── README.md
└── screenshots/
	├── Screenshot 2026-07-13 132330.png
	├── Screenshot 2026-07-13 132345.png
	├── Screenshot 2026-07-13 132522.png
	├── Screenshot 2026-07-13 132849.png
	├── Screenshot 2026-07-13 132906.png
	├── Screenshot 2026-07-13 134302.png
	├── Screenshot 2026-07-13 134331.png
	└── Screenshot 2026-07-13 134346.png
```

## Technologies Used
- Python 3
- Flask
- Git
- GitHub

## Author
Prabin Yadav
