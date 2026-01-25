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

1. **Build and deployment → Source:** choose **GitHub Actions**.
2. On the next push to `main`, the workflow will run and deploy. The site will be at the URL above.

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
