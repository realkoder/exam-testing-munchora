# Continuous Testing

Three different workflows defined at `.github/workflows/**`
since relying on GitHub Actions for the CI/Continuous Testing.

Quick explanation of the three different workflows:

1. **e2e.yml**
    - Runs system tests using _Cypress_ since testing both frontend and server.
2. **server-continuous-testing.yml**
    - Linting using _Rubocop_
    - Unit tests and integration tests with _RSpec_
    - API tests defined in _Postman_ using _Newman_
    - Connects with _SonarQube_ and uses _SonarScan_ to handle code coverage report.
    - **Artifacts**
        - api-tests-report.html
        - coverage.json
        - rubocop-report.json
3. **server-security.yml**
   - using _brakeman_ to scan Ruby on Rails application for any vulnerabilities.