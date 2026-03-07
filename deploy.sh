#!/bin/bash

# Deployment script for Recoguides Hugo site to Netlify
# Uses Netlify CLI and GitHub integration

set -e

echo "🚀 Starting Recoguides deployment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check if Netlify CLI is installed
if ! command -v netlify &> /dev/null; then
    echo -e "${YELLOW}Netlify CLI not found. Installing...${NC}"
    npm install -g netlify-cli
fi

# Check for Netlify token
if [ -z "$NETLIFY_AUTH_TOKEN" ]; then
    echo -e "${RED}NETLIFY_AUTH_TOKEN environment variable not set${NC}"
    echo -e "${YELLOW}Please set it with: export NETLIFY_AUTH_TOKEN='your-token'${NC}"
    exit 1
fi

# Login to Netlify
echo -e "${YELLOW}Authenticating with Netlify...${NC}"
netlify login --silent --auth "$NETLIFY_AUTH_TOKEN"

# Initialize Netlify site if not already done
if [ ! -f ".netlify/state.json" ]; then
    echo -e "${YELLOW}Initializing Netlify site...${NC}"
    netlify init --manual --force
fi

# Build site with Hugo
echo -e "${YELLOW}Building Hugo site...${NC}"
echo -e "${YELLOW}Note: Using Netlify Build will handle Hugo installation automatically${NC}"

# Check if we need to install Hugo locally
if ! command -v hugo &> /dev/null; then
    echo -e "${YELLOW}Hugo not found locally - Netlify Build will install it automatically${NC}"
fi

# Deploy to Netlify
echo -e "${YELLOW}Deploying to Netlify...${NC}"
DEPLOY_RESULT=$(netlify deploy --prod --dir=public 2>&1)

if [[ $DEPLOY_RESULT == *"Site deploy was successful"* ]]; then
    # Extract URL from output
    DEPLOY_URL=$(echo "$DEPLOY_RESULT" | grep -o 'https://.*\.netlify\.app' | head -1)
    
    if [ -n "$DEPLOY_URL" ]; then
        echo -e "${GREEN}✅ Deployment successful!${NC}"
        echo -e "${GREEN}Live site: $DEPLOY_URL${NC}"
        
        # Output for integration
        echo "DEPLOY_URL=$DEPLOY_URL" >> deploy.env
        echo "DEPLOY_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> deploy.env
        
        # Check for custom domain
        echo -e "${YELLOW}Checking custom domain configuration...${NC}"
        DOMAIN_CHECK=$(netlify domains:list 2>/dev/null | grep recoguides.com || true)
        
        if [ -n "$DOMAIN_CHECK" ]; then
            echo -e "${GREEN}✅ Custom domain recoguides.com is configured${NC}"
            echo -e "${GREEN}Your site should be accessible at: https://recoguides.com${NC}"
        else
            echo -e "${YELLOW}⚠️  Custom domain not configured${NC}"
            echo -e "${YELLOW}To add recoguides.com:${NC}"
            echo -e "${YELLOW}1. Go to Netlify dashboard → Site settings → Domain management${NC}"
            echo -e "${YELLOW}2. Add custom domain: recoguides.com${NC}"
            echo -e "${YELLOW}3. Update DNS records as instructed${NC}"
        fi
    else
        echo -e "${GREEN}✅ Deployment successful!${NC}"
        echo -e "${YELLOW}Could not extract URL from output. Check Netlify dashboard.${NC}"
    fi
else
    echo -e "${RED}❌ Deployment failed${NC}"
    echo "$DEPLOY_RESULT"
    exit 1
fi

echo ""
echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}🎉 Recoguides deployment complete!${NC}"
echo -e "${GREEN}=======================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Configure Tina.io CMS: https://tina.io/docs/hugo/"
echo -e "2. Set up Google Analytics"
echo -e "3. Add affiliate program links to articles"
echo -e "4. Submit sitemap to search engines"
echo ""

# Create deployment summary
cat > deployment-summary.md << EOF
# Deployment Summary

**Site:** Recoguides - Micro-SaaS Tool Comparison
**Time:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Status:** ✅ Deployed successfully
**URL:** ${DEPLOY_URL:-Check Netlify dashboard}
**Custom Domain:** $(if [ -n "$DOMAIN_CHECK" ]; then echo "✅ recoguides.com"; else echo "❌ Not configured"; fi)

## Next Actions
1. Test site functionality at URL above
2. Configure custom domain if needed
3. Connect Tina.io CMS for content management
4. Add Google Analytics tracking ID
5. Generate more comparison articles

## Content Created
- Project Management: Best tools for freelancers
- Time Tracking: Comprehensive review
- Site structure with 3 main categories
EOF

echo -e "${GREEN}Deployment summary saved to: deployment-summary.md${NC}"