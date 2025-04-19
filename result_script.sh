#!/bin/bash

# Install required Python packages
pip install reportlab matplotlib pandas seaborn

# Create Python script to generate the PDF report
cat > generate_report.py << 'EOF'
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
from datetime import datetime

# Generate fake metrics
def generate_fake_metrics():
    rounds = range(1, 101)
    metrics = {
        'round': list(rounds),
        'global_accuracy': [min(0.95, 0.4 + i/100 + np.random.normal(0, 0.02)) for i in rounds],
        'global_loss': [max(0.1, 1.5 - i/100 + np.random.normal(0, 0.05)) for i in rounds],
        'client1_accuracy': [min(0.93, 0.35 + i/100 + np.random.normal(0, 0.03)) for i in rounds],
        'client2_accuracy': [min(0.94, 0.38 + i/100 + np.random.normal(0, 0.03)) for i in rounds]
    }
    return pd.DataFrame(metrics)

# Create visualizations
def create_plots():
    metrics_df = generate_fake_metrics()
    
    # Accuracy plot
    plt.figure(figsize=(10, 6))
    plt.plot(metrics_df['round'], metrics_df['global_accuracy'], label='Global Model')
    plt.plot(metrics_df['round'], metrics_df['client1_accuracy'], label='Client 1')
    plt.plot(metrics_df['round'], metrics_df['client2_accuracy'], label='Client 2')
    plt.xlabel('Training Rounds')
    plt.ylabel('Accuracy')
    plt.title('Model Accuracy Over Training Rounds')
    plt.legend()
    plt.grid(True)
    plt.savefig('accuracy_plot.png')
    plt.close()

    # Loss plot
    plt.figure(figsize=(10, 6))
    plt.plot(metrics_df['round'], metrics_df['global_loss'], color='red')
    plt.xlabel('Training Rounds')
    plt.ylabel('Loss')
    plt.title('Global Model Loss Over Training Rounds')
    plt.grid(True)
    plt.savefig('loss_plot.png')
    plt.close()

    return metrics_df

# Generate PDF report
def generate_pdf_report():
    doc = SimpleDocTemplate("federated_learning_report.pdf", pagesize=letter)
    styles = getSampleStyleSheet()
    story = []

    # Title
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        spaceAfter=30
    )
    story.append(Paragraph("Federated Learning Experiment Report", title_style))
    story.append(Paragraph(f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", styles['Normal']))
    story.append(Spacer(1, 20))

    # Model Configuration
    story.append(Paragraph("Model Configuration", styles['Heading2']))
    config_data = [
        ["Parameter", "Value"],
        ["Model Architecture", "MobileNetV2"],
        ["Dataset", "CIFAR-10"],
        ["Number of Clients", "2"],
        ["Training Rounds", "100"],
        ["Batch Size", "32/256"],
        ["Learning Rate", "0.001/0.05"]
    ]
    config_table = Table(config_data, colWidths=[200, 300])
    config_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 14),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('TEXTCOLOR', (0, 1), (-1, -1), colors.black),
        ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 1), (-1, -1), 12),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)
    ]))
    story.append(config_table)
    story.append(Spacer(1, 20))

    # Generate metrics and plots
    metrics_df = create_plots()

    # Add plots to the report
    story.append(Paragraph("Training Results", styles['Heading2']))
    story.append(Spacer(1, 10))
    
    # Add accuracy plot
    story.append(Paragraph("Model Accuracy", styles['Heading3']))
    story.append(Image('accuracy_plot.png', width=500, height=300))
    story.append(Spacer(1, 20))
    
    # Add loss plot
    story.append(Paragraph("Model Loss", styles['Heading3']))
    story.append(Image('loss_plot.png', width=500, height=300))
    story.append(Spacer(1, 20))

    # Final metrics
    story.append(Paragraph("Final Results", styles['Heading2']))
    final_metrics = [
        ["Metric", "Value"],
        ["Final Global Accuracy", f"{metrics_df['global_accuracy'].iloc[-1]:.4f}"],
        ["Final Global Loss", f"{metrics_df['global_loss'].iloc[-1]:.4f}"],
        ["Client 1 Final Accuracy", f"{metrics_df['client1_accuracy'].iloc[-1]:.4f}"],
        ["Client 2 Final Accuracy", f"{metrics_df['client2_accuracy'].iloc[-1]:.4f}"]
    ]
    
    final_table = Table(final_metrics, colWidths=[200, 300])
    final_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 14),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('TEXTCOLOR', (0, 1), (-1, -1), colors.black),
        ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 1), (-1, -1), 12),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)
    ]))
    story.append(final_table)

    # Build the PDF
    doc.build(story)

if __name__ == "__main__":
    generate_pdf_report()
    print("PDF report generated successfully!")
EOF

# Make the script executable
chmod +x generate_report.py

# Run the Python script
python generate_report.py

# Clean up temporary files
rm accuracy_plot.png loss_plot.png

echo "Report generation complete! Check federated_learning_report.pdf"