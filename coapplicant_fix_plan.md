# Co-Applicant Multiple ID Issue - Analysis & Fix Plan

## Problem Statement
Multiple co-applicant IDs are being created:
1. First ID is created during PAN verification
2. Second ID is created during mobile verification

## Root Cause
In `co_applicant.dart`:
1. **PAN Verification**: Does NOT capture the `coApplicantId` returned from backend
2. **Mobile/Email Verification**: Backend creates new co-applicant since no ID is passed

## Fix Plan

### File: lib/presentation/role/rm/NewCustomer/co_applicant.dart

1. **Fix _verifyPanNumber() method (around line 1070-1120)**
   - Uncomment/pass coApplicantId parameter
   - Capture coApplicantId from the API response after PAN verification
   
2. **Fix _sendMobileOtp() method (around line 900-930)**
   - Ensure coApplicantId is passed to the API call
   
3. **Fix _verifyMobileOtp() method (around line 950-990)**
   - Ensure coApplicantId is passed to the API call
   
4. **Fix _sendEmailOtp() method (around line 1010-1040)**
   - Ensure coApplicantId is passed to the API call
   
5. **Fix _verifyEmailOtp() method (around line 1060-1090)**
   - Ensure coApplicantId is passed to the API call

## Implementation Steps
- Step 1: Update PanVerifyService call to pass coApplicantId and capture response
- Step 2: Update all subsequent API calls to use the captured coApplicantId
