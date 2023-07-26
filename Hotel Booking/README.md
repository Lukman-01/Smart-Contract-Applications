# Hotel Booking Contract Project

Based on the V1 smart contract, some potential security vulnerabilities and to be solved are as follows:

1. **No Access Control for Adding Rooms**: Currently, any address can call the `addRoom` function and add a new room to the contract. Consider adding a modifier or function to restrict access to only authorized parties, such as the contract owner or specific roles. Done.

2. **Lack of Ownership Management**: The contract does not have a mechanism for transferring ownership, which could be risky if the landlord's address needs to be changed or updated. Adding a function to transfer ownership to a new address could be useful. Done.

3. **No Limit on Lock Period**: The `signAgreement` function allows tenants to set any value for the `_lockperiod`, which could potentially be abused. Consider adding a maximum limit for the lock period or using a more secure approach to determine the agreement duration. Done

4. **Potential Integer Overflow**: There are multiple arithmetic operations in the contract (e.g., incrementing `no_of_rooms`, `no_of_rent`, `no_of_agreement`). If these variables reach their maximum value, an integer overflow may occur, leading to unexpected behavior. It's essential to handle such cases with proper checks and safeguards.

5. **Front-Running on Timestamp-based Modifiers**: The modifiers that rely on `block.timestamp`, such as `AgreementTimeLeft`, `AgreementTimesUp`, and `RentTimesUp`, could be susceptible to front-running attacks. Consider using block numbers or more secure timestamp verification mechanisms.

6. **Lack of Error Handling in Transfer Functions**: The contract uses `transfer` to send ether, which may revert the entire transaction if the transfer fails. Consider using `send` or `call` and implementing appropriate error handling to avoid potential denial of service (DoS) vulnerabilities.

7. **No Termination Penalty**: The `agreementTerminated` function allows the landlord to terminate an agreement without any penalty for early termination. Consider adding a penalty mechanism to protect the tenant's interests.

8. **Lack of Withdrawal Mechanism for Security Deposit**: Currently, there is no way for the tenant to withdraw their security deposit after the agreement ends successfully. Consider adding a function for the tenant to reclaim their security deposit when the agreement is completed.

9. **Inconsistent Naming Conventions**: Ensure consistent naming conventions for variables and functions to improve code readability and avoid potential confusion.
