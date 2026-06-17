 For fg-cw-backend

  # 1. Navigate to the repo
  cd /Users/nitinmali/workspace/farming/fg-cw-backend

  # 2. Ensure you have latest changes from remote
  git checkout main
  git fetch origin

  # 3. Checkout the hotfix branch
  git checkout hotfix/perf-test-seed

  # 4. Rebase onto main
  git rebase origin/main

  # 5. If there are conflicts:
  #    - Git will pause and show conflicted files
  #    - Edit the files to resolve conflicts
  #    - Stage the resolved files: git add <file>
  #    - Continue rebase: git rebase --continue
  #    - Repeat until rebase completes

  # 6. Force push the rebased branch (ONLY do this on hotfix branch, never on main!)
  git push --force origin hotfix/perf-test-seed

  # 7. Verify the branch is up to date
  git log --oneline -5

  For fg-gas-backend

  # 1. Navigate to the repo
  cd /Users/nitinmali/workspace/farming/fg-gas-backend

  # 2. Ensure you have latest changes from remote
  git checkout main
  git fetch origin

  # 3. Checkout the hotfix branch
  git checkout hotfix/perf-test-seed

  # 4. Rebase onto main
  git rebase origin/main

  # 5. If there are conflicts:
  #    - Git will pause and show conflicted files
  #    - Edit the files to resolve conflicts
  #    - Stage the resolved files: git add <file>
  #    - Continue rebase: git rebase --continue
  #    - Repeat until rebase completes

  # 6. Force push the rebased branch
  git push --force origin hotfix/perf-test-seed

  # 7. Verify the branch is up to date
  git log --oneline -5

  Important Notes:

  If rebase fails or you want to abort:
  git rebase --abort

  If you see conflicts during rebase:
  1. Open the conflicted files in your editor
  2. Look for conflict markers: <<<<<<<, =======, >>>>>>>
  3. Edit to keep the code you want
  4. Remove the conflict markers
  5. Save the file
  6. Stage it: git add <filename>
  7. Continue: git rebase --continue

  After force pushing:
  - Verify in GitHub that the hotfix branch looks correct
  - Check the commit history to ensure it includes latest main commits
  - Redeploy in CDP if needed

  Common Rebase Conflicts You Might See:
  - Changes to package.json or package-lock.json
  - Changes to migration files
  - Changes to the same files you modified in hotfix

Then go to https://github.com/DEFRA/fg-cw-backend/actions
Click on 'Publish hot fix'
Clcik on run workflow and select the branch hotfix/perf-test-seed
And click 'Run workflow'

Go to https://github.com/DEFRA/fg-gas-backend/actions
Click on 'Publish hot fix'
Clcik on run workflow and select the branch hotfix/perf-test-seed
And click 'Run workflow'

Deploy both hotfix branches to the perf-test environment (Refer to future-grants-perf-tests/docs/how-to-run-tests.md)
Deploy the latest UI
