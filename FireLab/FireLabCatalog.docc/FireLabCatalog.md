# ``FireLab``

This app will calculate your earliest possible retirement plan. 

## Overview

Provide your details and your investment preferences, and the app will calculate the amount of your income to send to your brokerage account/s and the amount to contribute towards your superannuation account. It will also display graphs visualising the user's financial journey. FIRE = Financial Independence, Retiring Early. Based on the FIRE movement.

The app will ask the user in the beginning to provide details of their current situation, income, age and expenses. They can set details for housing, current debts and current investment portfolio, different to the investments the user plans to invest into in the future. Then their future investment plans can be customised in the subsequent screen. 

The calculation works by figuring out the minimum amount the user needs to grow their brokerage and super investments to, in order for the brokerage fund to last them until the age of 60 and the super fund to last them from the ages of 60 to 67. It will also give them the time it will occur based on their FI contribution.

Some assumptions are made for our *limited* financial forecaster:
- The user will retire no matter what at 67 years of age. Regardless of their expenses or assets. Once they recieve the pension, they are considered retired, and do not have to work.
- The only available ETFs are U.S based ETFs as the API only allows U.S based ETFs to be available on the free tier. Currency will be converted to AUD.
- The user will take tax into account when providing their own yearly return percentage.
- The user never wants to default on any of their loans.
- The user provide details such that they can pay off their debt before they reach 67. As this is not a completely comprehensive financial planner, if the user wants to ensure they pay off their debts, they will have to set higher minimum monthly payments for their debts.
- The feature for the PortfolioDetailsView screen wasn't fully thought-out. I thought users should be able to communicate their current assets as well, but didn't realise there are simpler approaches to do them in.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
