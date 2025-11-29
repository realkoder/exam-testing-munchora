export function deleteListIfExist() {
  cy.document().then((doc) => {
    const deleteBtns = doc.querySelectorAll('button[cy-data="delete-list-btn"]');

    if (deleteBtns.length) {
      cy.wrap(deleteBtns[0]).click({force: true});

      cy.get('[role="dialog"]').should('be.visible').within(() => {
        cy.contains('button', 'Delete').click({force: true});
      });

      cy.wrap(deleteBtns[0]).should('not.exist').then(() => {
        if (deleteBtns.length > 1) deleteListIfExist();
      });
    }
  });
}