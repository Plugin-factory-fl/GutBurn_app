# GutBurn Website

Three-page static site for the **GutBurn** app: Homepage, Privacy Policy, and Support.  
Built to satisfy **Apple App Store** requirements for **Privacy Policy URL** and **Support URL**, and to support app discovery and conversions.

---

## Deployment (GitHub Pages)

The site is deployed from the **`Website/`** subfolder via GitHub Actions.

- **Workflow:** `.github/workflows/deploy-pages.yml` runs on push to `main`
- **Live URL:** https://plugin-factory-fl.github.io/GutBurn_app/

### Enable GitHub Pages

In the repo **Settings → Pages**:

1. **Build and deployment → Source:** choose **Deploy from a branch** (not "GitHub Actions").
2. **Branch:** select **gh-pages** and **/ (root)**. If `gh-pages` isn’t listed yet, push to `main` once so the workflow creates it, then select it.
3. Save. On each push to `main`, the workflow publishes `Website/` to `gh-pages` and Pages serves the site at the URL above.

---

## Pages & App Store URLs

| Page     | URL                                                                 |
|----------|---------------------------------------------------------------------|
| Homepage | https://plugin-factory-fl.github.io/GutBurn_app/                   |
| Privacy  | https://plugin-factory-fl.github.io/GutBurn_app/privacy.html      |
| Support  | https://plugin-factory-fl.github.io/GutBurn_app/support.html       |

### In App Store Connect

- **Privacy Policy URL:**  
  `https://plugin-factory-fl.github.io/GutBurn_app/privacy.html`

- **Support URL (English (U.S.)):**  
  `https://plugin-factory-fl.github.io/GutBurn_app/support.html`

---

## File structure

```
Website/
├── index.html      # Homepage
├── privacy.html    # Privacy Policy (for Privacy Policy URL)
├── references.html # Sources & references (for in-app citations, Guideline 1.4.1)
├── support.html    # Support (for Support URL)
├── styles.css      # Shared styles
└── README.md       # This file
```

---

## App & contact (current)

- **App Store:** https://apps.apple.com/app/id4823314701  
- **Support email:** megamix.ai.plugins@gmail.com  

---

## Tech

- Plain HTML and CSS; no build step.
- Responsive layout, works on mobile and desktop.
- Uses DM Sans from Google Fonts.
- No JavaScript required for the core experience.
