---
name: architecture-visualizer
description: Architecture visualization tool with pre-defined high-quality templates. Use when a user needs to visualize cloud infrastructure, CI/CD pipelines, or system designs in a clean, professional format (e.g., Apple-style or EKS-CI/CD style).
---

# Architecture Visualizer

This skill provides a collection of professional HTML/CSS templates for infrastructure and process visualization.

## Available Templates

### 1. EKS CI/CD Style (`assets/templates/eks-cicd-template.html`)
A structured, phased flow ideal for pipelines and multi-step infrastructure deployments.
- **Key Features**: Phase labels, vertical connectors, colored detail chips.
- **Best For**: CI/CD workflows, AWS/EKS deployments, phased roadmaps.

### 2. GCP Tree Style (`assets/templates/gcp-lb-tree-template.html`)
A tree-structured layout ideal for GCP infrastructure with nested resource hierarchies.
- **Key Features**: Monospace tree connectors, color-coded highlight chips (GCP blue/green/yellow/red), two sections (LB + Network).
- **Best For**: GCP Load Balancer + MIG, VPC network topology, resource hierarchy visualization.

### 3. Apple Minimalist Style (Workflow)
A clean, premium design with soft shadows and Glassmorphism.
- **Key Features**: SF-style typography, minimal borders, A->B->C flow.
- **Best For**: High-level system overviews, pitch decks, user-facing documentation.

## How to Use

1. **Select Template**: Choose the template that best fits the user's data.
2. **Populate Content**: Replace placeholders in the HTML with the user's specific infrastructure/process details.
3. **Customize Colors**: Use the CSS variables defined in the `:root` to match specific cloud providers (e.g., Azure Blue, AWS Orange, GCP Green).
4. **Generate Image**:
   - Save the populated HTML.
   - Run headless Chrome to capture the screenshot:
     ```bash
     "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu --screenshot=output.png --window-size=1200,1600 file://$(pwd)/temp.html
     ```

## Design Principles

- **Clarity**: Use connectors to show data flow.
- **Consistency**: Keep icon sizes and spacing uniform.
- **Hierarchy**: Use bold headers and muted labels to guide the eye.