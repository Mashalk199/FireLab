#  Readme

Consider adding sections that explain what the project does, how to set it up, key features, technologies used, and any challenges or future improvements. A clear, well-documented README makes your good version control practices even more valuable.

## Purpose
FireLab is an app that uses your personal financial details to provide a retirement plan for you to achieve FIRE (Financial Independence, Retire Early) earliest. 
## Key Features
- Calculates the earliest date you can retire, using a risky early retirement approach where you only invest into your super and brokerage accounts such that your brokerage account will barely last you until the age of 60, and the growth in your super account will take care of the rest (and afterwards the pension).
- Takes personal loans, mortgage, current assets and inflation into account.
- Machine learning can be enabled to improve accuracy of retirement calculation by using real-life financial data of real ETF's.
- Interactive graphs with custom gestures are also provided to let users visualise their financial journey.

## Demo – Gesture interaction
https://github.com/Mashalk199/FireLab/blob/main/Docs/gesture-demo.mp4
<video src="Docs/result-demo.mp4" autoplay loop muted playsinline width="300"></video>

How to run app:

1. Create an account on twelvedata.com
2. Rename the plist file called "Secrets.sample.plist" to "Secrets.plist". 
3. In the file, in the key "FinancialAPIKey" and put your twelvedata API key as the value of the pair.
4. Cmd + R on Xcode.
