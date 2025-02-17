#!/bin/bash
# scripts/generate_report.sh

echo "Generating security report..."

cat << 'EOF' > security-results/report.html
<!DOCTYPE html>
<html>
<head>
    <title>Security Scan Results</title>
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
            color: #333;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 4px;
        }
        .tool-section {
            margin-bottom: 40px;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        /* Colorful Headers for Each Tool */
        .tool-section.sonarqube h2 {
            background: #4c9bd6;  /* Blue */
            color: white;
        }
        .tool-section.snyk h2 {
            background: #582d82;  /* Purple */
            color: white;
        }
        .tool-section.trivy h2 {
            background: #2d9882;  /* Teal */
            color: white;
        }
        .tool-section.zap h2 {
            background: #d63619;  /* Red-Orange */
            color: white;
        }
        .tool-section h2 {
            padding: 15px 20px;
            margin: -20px -20px 20px -20px;
            border-radius: 4px 4px 0 0;
        }
        .vulnerability-item {
            margin: 15px 0;
            padding: 15px;
            background: #f8f9fa;
            border-left: 4px solid #ddd;
            border-radius: 4px;
        }
        .severity-critical { border-left-color: #7d0000; }
        .severity-high { border-left-color: #d73a4a; }
        .severity-medium { border-left-color: #fb8c00; }
        .severity-low { border-left-color: #ffca28; }
        .severity-info { border-left-color: #0366d6; }
        
        .vulnerability-title {
            font-weight: bold;
            margin-bottom: 10px;
        }
        .metadata {
            font-size: 0.9em;
            color: #666;
            margin: 5px 0;
        }
        .severity-badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 0.8em;
            font-weight: bold;
            color: white;
        }
        .badge-critical { background-color: #7d0000; }
        .badge-high { background-color: #d73a4a; }
        .badge-medium { background-color: #fb8c00; }
        .badge-low { background-color: #ffca28; color: #333; }
        .badge-info { background-color: #0366d6; }
        
        .stats {
            display: flex;
            justify-content: space-around;
            margin: 20px 0;
            flex-wrap: wrap;
            background: rgba(255, 255, 255, 0.9);
            padding: 15px;
            border-radius: 4px;
        }
        .stat-item {
            text-align: center;
            padding: 15px;
            background: white;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin: 10px;
            min-width: 150px;
        }
        .stat-number {
            font-size: 24px;
            font-weight: bold;
            margin: 10px 0;
        }
        .description {
            margin: 10px 0;
            padding: 10px;
            background: #f8f9fa;
            border-radius: 4px;
        }
        .solution {
            margin: 10px 0;
            padding: 10px;
            background: #e3f2fd;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Security Scan Results</h1>
            <p>Generated on $(date)</p>
            <p>Repository: $GITHUB_REPOSITORY</p>
            <p>Branch: $GITHUB_REF</p>
        </div>

        <!-- SonarQube Results -->
        <div class="tool-section sonarqube">
            <h2>Static Application Security Testing (SonarQube)</h2>
            <div class="stats">
                $(jq -r '.issues | group_by(.severity) | map({severity: .[0].severity, count: length}) | map("<div class=\"stat-item\"><div class=\"stat-number\">" + (.count|tostring) + "</div><div>" + .severity + "</div></div>") | join("")' security-results/sonarqube/issues.json 2>/dev/null || echo "<div class='stat-item'><div>No results available</div></div>")
            </div>
            <div class="findings">
                $(jq -r '.issues[] | "<div class=\"vulnerability-item severity-" + (.severity|ascii_downcase) + "\"><div class=\"vulnerability-title\">" + .message + "</div><div class=\"metadata\">Location: " + .component + "</div><div class=\"metadata\">Type: " + .type + "</div></div>"' security-results/sonarqube/issues.json 2>/dev/null || echo "<p>No issues found</p>")
            </div>
        </div>

        <!-- Snyk Results -->
        <div class="tool-section snyk">
            <h2>Software Composition Analysis (Snyk)</h2>
            <div class="findings">
                $(jq -r '.vulnerabilities[] | "<div class=\"vulnerability-item severity-" + (.severity|ascii_downcase) + "\"><div class=\"vulnerability-title\">" + .title + "</div><div class=\"metadata\">Package: " + .package + " (Version: " + .version + ")</div><div class=\"metadata\">Fixed in: " + (.fixedIn[0] // "No fix available") + "</div><div class=\"description\">" + .description + "</div></div>"' security-results/snyk/scan-results.json 2>/dev/null || echo "<p>No vulnerabilities found</p>")
            </div>
        </div>

        <!-- Trivy Results -->
        <div class="tool-section trivy">
            <h2>Container Security (Trivy)</h2>
            <div class="findings">
                $(jq -r '.Results[]? | .Vulnerabilities[]? | "<div class=\"vulnerability-item severity-" + (.Severity|ascii_downcase) + "\"><div class=\"vulnerability-title\">" + .VulnerabilityID + ": " + .Title + "</div><div class=\"metadata\">Package: " + .PkgName + " (Version: " + .InstalledVersion + ")</div><div class=\"metadata\">Fixed Version: " + (.FixedVersion // "No fix available") + "</div></div>"' security-results/trivy/scan-results.json 2>/dev/null || echo "<p>No vulnerabilities found</p>")
            </div>
        </div>

        <!-- ZAP Results -->
        <div class="tool-section zap">
            <h2>Dynamic Application Security Testing (OWASP ZAP)</h2>
            <div class="findings">
                $(jq -r '.site[]?.alerts[]? | "<div class=\"vulnerability-item severity-" + (if .riskcode == "3" then "critical" elif .riskcode == "2" then "high" elif .riskcode == "1" then "medium" else "low" end) + "\"><div class=\"vulnerability-title\">" + .name + "</div><div class=\"metadata\">Risk Level: " + .riskdesc + "</div><div class=\"description\">" + .desc + "</div><div class=\"solution\"><strong>Solution:</strong><br/>" + .solution + "</div></div>"' security-results/zap/zap-output.json 2>/dev/null || echo "<p>No vulnerabilities found</p>")
            </div>
        </div>
    </div>
</body>
</html>
EOF

echo "Report generated successfully at security-results/report.html"
