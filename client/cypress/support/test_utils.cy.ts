export function deleteListIfExist() {
  cy.document().then((doc) => {
    const deleteBtns = doc.querySelectorAll('button[cy-data="delete-list-btn"]');
    if (deleteBtns.length) {
      deleteBtns.forEach((btn) => {
        cy.wrap(btn).click({ force: true });
        cy.get('[role="dialog"]').should('be.visible').within(() => {
          cy.contains('button', 'Delete').click({ force: true });
        });
      });
    } else {
      cy.log('No grocery lists to delete');
    }
  });
}