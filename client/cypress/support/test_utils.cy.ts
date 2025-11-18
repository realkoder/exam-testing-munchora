export function deleteListIfExist() {
  cy.get('body').then(($body) => {
    const deleteBtn = $body.find('button[cy-data="delete-list-btn"]');
    if (deleteBtn.length) {
      cy.wrap(deleteBtn).each(($btn) => {
        // Click the initial delete button (opens modal)
        cy.wrap($btn).click({ force: true });

        // Wait for modal to appear and click the actual Delete button inside it
        cy.get('[role="dialog"]') // Radix Dialog has role="dialog"
          .should('be.visible')
          .within(() => {
            // Click the button that says "Delete" (not "Cancel")
            cy.contains('button', 'Delete').click({ force: true });
          });
      });
    }
  });
}