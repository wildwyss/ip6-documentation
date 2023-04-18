# Git Commit Convention
---
##Resources: 

[Commit Message Guideline](https://www.conventionalcommits.org/en/v1.0.0/#summary)23.02.2023

[Angular Commit Conventions](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines)23.02.2023

## Types
- docs: Documentation only changes
- feat: A new feature
- fix: A bug fix
- refactor: A code change that neither fixes a bug nor adds a feature
- test: Adding missing tests or correcting existing tests
- style: Changes that do not affect the meaning of the code (white space, formatting, missing semicolons, etc.)

### Breaking Changes
To indicate a breaking change, use an exclamation mark after the type.


## Scope
The scope is written in braces after the type.

## Description
- uses the imperative, present tense: "change" not "changed" nor "changes"
- don't capitalize the first letter
- no dot (.) at the end

## Optional

### Body
The body is optional for further information.

### Footer
Is to reference an issue or indicate a breaking change using _BREAKING CHANGE:_.


## Example

```bash
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

```bash
git commit -m "feat(iterator): implement map"
```
