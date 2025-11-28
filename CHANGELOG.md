# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-01-28

### Added

- **Component Registration DSL** - `register_component` method for declaring UI components with schema validation
- **Schema Validation** - Integration with dry-schema for automatic component data validation in development
- **Base Page Classes**
  - `BetterPage::BasePage` - Foundation class with helper methods
  - `BetterPage::IndexBasePage` - For list/index views with `header` and `table` components
  - `BetterPage::ShowBasePage` - For detail views with `header` component
  - `BetterPage::FormBasePage` - For new/edit forms with `header` and `panels` components
  - `BetterPage::CustomBasePage` - For dashboards and custom views with `content` component
- **Compliance Analyzer** - Tool to verify pages follow architecture rules (no database queries, no business logic)
- **Rails Generators**
  - `better_page:install` - Sets up `app/pages/` directory and `ApplicationPage` base class
  - `better_page:page` - Generates page classes for specified actions
- **Documentation**
  - API reference in `docs/` folder
  - Step-by-step guides in `guide/` folder
- **Rake Tasks**
  - `better_page:compliance:analyze` - Analyze all pages for compliance issues
