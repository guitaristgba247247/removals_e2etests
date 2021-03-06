@mvmt
Feature: Movements
  Background:
    Given I am a logged in user
    And There are no existing centres
    And The following centres exist:
      | name | male_capacity | female_capacity | male_cid_name  | female_cid_name |
      | one  | 1000          | 10000           | oneman,onebman | one woman       |
    And I am on the wallboard
    Then The Centre "one" should show the following under "Male":
      | In use              | 0    |
      | Out of commission   | 0    |
      | Contingency         | 0    |
      | Prebooked           | 0    |
      | Estimated available | 1000 |
      | Outgoing            | 0    |

  Scenario: Unreconciled Out Movement shows as Expected Outgoing and does not affect Availability
    When I submit the following movements:
      | MO In/MO Out | Location  | MO Ref | MO Date | MO Type | CID Person ID |
      | Out          | oneman    | 111    | now     | Removal | 1433          |
      | Out          | one woman | 112    | now     | Removal | 1434          |
    Then The Centre "one" should show the following under "Male":
      | In use              | 0    |
      | Out of commission   | 0    |
      | Contingency         | 0    |
      | Prebooked           | 0    |
      | Estimated available | 1000 |
      | Incoming            | 0    |
      | Outgoing            | 1    |
    And the Centre "one" should show the following CIDS under "Male" "Outgoing":
      | CID Person ID |
      | 1433          |
    Then The Centre "one" should show the following under "Female":
      | Outgoing | 1 |
    And the Centre "one" should show the following CIDS under "Female" "Outgoing":
      | CID Person ID |
      | 1434          |

  Scenario: Unreconciled In Movement shows as Expected incoming and reduces availability
    When I submit the following movements:
      | MO In/MO Out | Location | MO Ref | MO Date | MO Type | CID Person ID |
      | In           | oneman   | 111    | now     | Removal | 12345555      |
    Then The Centre "one" should show the following under "Male":
      | In use              | 0   |
      | Out of commission   | 0   |
      | Contingency         | 0   |
      | Prebooked           | 0   |
      | Estimated available | 999 |
      | Incoming            | 1   |
      | Outgoing            | 0   |
    And the Centre "one" should show the following CIDS under "Male" "Incoming":
      | CID Person ID |
      | 12345555      |

  Scenario: Non-occupancy Movements that relate to a port should still be ignored
    When I submit the following movements:
      | MO In/MO Out | Location | MO Ref | MO Date | MO Type       | CID Person ID |
      | Out          | Big Port | 110    | now     | Non-Occupancy | 12345555      |
      | In           | oneman   | 110    | now     | Non-Occupancy | 12345555      |
      | Out          | oneman   | 111    | now     | Non-Occupancy | 12345555      |
      | In           | Big Port | 111    | now     | Non-Occupancy | 12345555      |
    Then The Centre "one" should show the following under "Male":
      | Estimated available | 1000 |
      | Incoming            | 0    |
      | Outgoing            | 0    |

  Scenario: Non-occupancy Movements that relate to a port should be ignored if there is a matching reinstatement
    And The following detainee exists:
      | centre      | one      |
      | cid_id      | 12345555 |
      | person_id   | 1234     |
      | gender      | m        |
      | nationality | abc      |
    And I submit the following "reinstatement" event:
      | centre    | one  |
      | timestamp | now  |
      | person_id | 1234 |
    When I submit the following movements:
      | MO In/MO Out | Location | MO Ref | MO Date | MO Type       | CID Person ID |
      | Out          | Big Port | 110    | now     | Non-Occupancy | 12345555      |
      | In           | oneman   | 110    | now     | Non-Occupancy | 12345555      |
      | Out          | oneman   | 111    | now     | Non-Occupancy | 12345555      |
      | In           | Big Port | 111    | now     | Non-Occupancy | 12345555      |
    Then The Centre "one" should show the following under "Male":
      | Estimated available | 1000 |
      | Incoming            | 0   |
      | Outgoing            | 0   |

  Scenario: Non-occupancy Movements that relate to a port should still ignored if the reinstatement is too old
    When I submit the following movements:
      | MO In/MO Out | Location | MO Ref | MO Date | MO Type       | CID Person ID |
      | Out          | Big Port | 110    | now     | Non-Occupancy | 12345555      |
      | In           | oneman   | 110    | now     | Non-Occupancy | 12345555      |
      | Out          | oneman   | 111    | now     | Non-Occupancy | 12345555      |
      | In           | Big Port | 111    | now     | Non-Occupancy | 12345555      |
    And The following detainee exists:
      | centre      | one      |
      | cid_id      | 12345555 |
      | person_id   | 1234     |
      | gender      | m        |
      | nationality | abc      |
    And I submit the following "reinstatement" event:
      | centre    | one         |
      | timestamp | 4 hours ago |
      | person_id | 1234        |
    Then The Centre "one" should show the following under "Male":
      | Estimated available | 1000 |
      | Incoming            | 0    |
      | Outgoing            | 0    |

  Scenario: Movements within a centre should not appear
    When I submit the following movements:
      | MO In/MO Out | Location | MO Ref | MO Date | MO Type | CID Person ID |
      | In           | oneman   | 111    | now     | Removal | 1433          |
      | Out          | onebman  | 111    | now     | Removal | 1433          |
      | Out          | onebman  | 112    | now     | Removal | 1434          |
    Then The Centre "one" should show the following under "Male":
      | Incoming | 0 |
      | Outgoing | 1 |
