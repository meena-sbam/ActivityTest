*** Settings ***
Library     RequestsLibrary
Library     JSONLibrary
Library     Collections
Library     OperatingSystem
#Library     HttpLibrary.HTTP
Resource        resource.robot
Test Setup     Session Creation
Test Teardown      Delete All Sessions

*** Variables ***
${url}=     https://gorest.co.in/
${AUTH_BEARER}=     Create Dictionary
${AUTH_BEARER}=     Get Token
${headers}=     Create Dictionary       Content-Type=application/json Authorization=Bearer${AUTH_BEARER}

*** Test Cases ***

Verify Response has Pagination
        ${response}=    Get Request         /public/v2/users        200      ${headers}
        #Verifying pagination with header availability of 'x-pagination-page'
        should contain      ${response.headers}     x-pagination-page
        #Verifying pagination by performing get request with page details in query parameters
        ${response_with_page}=    Get Request         /public/v2/users?page=1&per_page=10        200

























