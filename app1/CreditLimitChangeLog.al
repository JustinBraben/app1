// CreditLimitChangeLog.al
table 50101 "Credit Limit Change Log"
{
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
        }
        field(3; "Change Date"; Date)
        {
            Caption = 'Change Date';
        }
        field(4; "Old Credit Limit"; Decimal)
        {
            Caption = 'Old Credit Limit';
            DecimalPlaces = 0:2;
        }
        field(5; "New Credit Limit"; Decimal)
        {
            Caption = 'New Credit Limit';
            DecimalPlaces = 0:2;
        }
        field(6; "Change Percentage"; Decimal)
        {
            Caption = 'Change Percentage';
            DecimalPlaces = 0:2;
        }
        field(7; "User ID"; Code[50])
        {
            Caption = 'User ID';
        }
    }
    
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(CustomerDate; "Customer No.", "Change Date")
        {
        }
    }
}