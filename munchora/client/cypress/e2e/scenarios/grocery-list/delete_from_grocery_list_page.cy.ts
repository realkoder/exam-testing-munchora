import {deleteListIfExist} from '../../../support/test_utils.cy';

describe('Grocery List - Delete', () => {
  beforeEach(() => {
    cy.loginOrSignUpByApi();
    cy.loadPage('groceryLists');
  });

  it('deletes grocery list successfully', () => {
    cy.contains('button', 'Create Your First List').click();
    cy.get('input[placeholder="Name Of Shopping List"]').should('have.value', 'Shopping 🛒');
    deleteListIfExist();
    cy.contains('h3', 'No grocery lists yet').should('be.visible');
  });
});
