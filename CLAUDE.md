# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the CITY 4C project - a civic engagement application system that allows citizens and public agents to report municipal issues through 7-second video recordings with geolocation metadata.

## Architecture

The project is structured in 4 main directories:

- **APP/**: Flutter mobile application (cross-platform for Android/iOS)
- **SITE/**: Vue.js web administrative panel
- **ARQUIVOS E ESTRUTURA SQL/**: Database structure files and SQL commands
- **DOCUMENTACAO/**: Project documentation including MVP specifications

## Tech Stack

- **Mobile App**: Flutter for cross-platform development
- **Web Panel**: Vue.js frontend
- **Backend**: Supabase (PostgreSQL with geospatial support)
- **Storage**: Supabase Storage for videos/images
- **Authentication**: Supabase Auth

## Key Features (MVP)

- 7-second video recording with automatic geolocation metadata
- Agent authentication vs anonymous citizen access
- Tag-based categorization system
- Administrative dashboard with interactive maps
- Video encryption before upload
- Automatic device cleanup after successful upload

## Development Notes

- Currently in project setup phase - no code files exist yet
- Follow the MVP specification in `DOCUMENTACAO/ProjetoMVP.md`
- Structure follows the folder organization defined in `EstruturaPasta.md`
- Focus on essential functionality for proof of concept validation

## Project Structure

```
CITY 4C/
├── APP/                    # Flutter mobile application
├── SITE/                   # Vue.js admin panel
├── ARQUIVOS E ESTRUTURA SQL/  # Database files
└── DOCUMENTACAO/          # Project specifications
```

When starting development, create the appropriate project scaffolding in the APP/ and SITE/ directories according to the defined tech stack.