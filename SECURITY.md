# Security Policy

This document outlines security procedures and general policies for the
`compact-tree-sitter` project.

- [Supported versions](#supported-versions)
- [Disclosing a security issue](#disclosing-a-security-issue)
- [Vulnerability management](#vulnerability-management)
- [Suggesting changes](#suggesting-changes)

## Supported versions

This project is pre-1.0. Only the latest published release is supported with
security fixes.

## Disclosing a security issue

We take all security issues seriously. If you believe you have found a security
vulnerability in this repository, **please report it using GitHub's private
vulnerability reporting** and not through public GitHub issues.

To report a vulnerability, open a private security advisory at:

https://github.com/1NickPappas/compact-tree-sitter/security/advisories/new

For more information about GitHub's private vulnerability reporting, see
[GitHub's documentation][private-reporting].

Please include as much of the following information as you can to help us
understand the nature and scope of the issue:

- The repository name or URL
- Type of issue (buffer overflow, out-of-bounds read, etc.)
- Full paths of the source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any particular configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

A maintainer will acknowledge the report within three (3) business days and
will send a more detailed response within an additional three (3) business days
indicating the next steps in handling the report.

After the initial reply, the maintainer will endeavor to keep you informed of
the progress towards a fix and full announcement, and may ask for additional
information or guidance.

Thank you for improving the security of this project. We appreciate your
dedication to responsible disclosure.

## Vulnerability management

When the maintainer receives a disclosure report, they will coordinate the fix
and release process, which involves the following steps:

- confirming the issue
- determining affected versions of the project
- auditing code to find any potential similar problems
- preparing fixes for all releases under maintenance

## Preferred languages

We prefer all communications to be in English.

## Suggesting changes

If you have suggestions on how this process could be improved, please submit an
issue or pull request.

[private-reporting]: https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability
