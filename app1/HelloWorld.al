// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

pageextension 50000 CustomerListExt extends "Customer List"
{
    actions
    {
        AddLast("&Customer")
        {
            action(UpdateCreditLimit)
            {
                ApplicationArea = All;
                Caption = 'Update Credit Limit';
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Calculate and update the credit limit for the selected customer.';

                trigger OnAction()
                var
                    CreditManager: Codeunit "Customer Credit Manager";
                    SuccessMsg: Label 'Credit limit updated successfully.';
                    NoSelectionMsg: Label 'Please select a customer.';
                begin
                    if Rec.IsEmpty then begin
                        Message(NoSelectionMsg);
                        exit;
                    end;

                    if CreditManager.UpdateCustomerCreditLimit(Rec) then
                        Message(SuccessMsg)
                    else
                        Error('Failed to update credit limit for customer %1.', Rec."No.");
                end;
            }
        }
    }
    trigger OnOpenPage();
    begin
        Message('Your App was published: Hello world');
    end;
}

