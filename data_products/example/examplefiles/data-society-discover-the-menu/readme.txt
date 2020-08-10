This dataset is split into four files to minimize the amount of redundant information contained in each (and thus, the size of each file). The four data files are Menu, MenuPage, MenuItem, and Dish. These four files are described briefly here, and in detail in their individual file descriptions below.

============================================================================================================


Files :
-------
Menu.csv                   : The core element of the dataset. Each Menu has a unique identifier and associated data, including data on the venue and/or event that the menu was created for; the location that the menu was used; the currency in use on the menu; and various other fields. Each menu is associated with some number of MenuPage values.

MenuPage.csv               : Each MenuPage refers to the Menu it comes from, via the menu_id variable (corresponding to Menu:id). Each MenuPage also has a unique identifier of its own. Associated MenuPage data includes the page number of this MenuPage, an identifier for the scanned image of the page, and the dimensions of the page. Each MenuPage is associated with some number of MenuItem values.

MenuItem.csv               : Each MenuItem refers to both the MenuPage it is found on -- via the menu_page_id variable -- and the Dish that it represents -- via the dish_id variable. Each MenuItem also has a unique identifier of its own. Other associated data includes the price of the item and the dates when the item was created or modified in the database.

Dish.csv                   : A Dish is a broad category that covers some number of MenuItems. Each dish has a unique id, to which it is referred by its affiliated MenuItems. Each dish also has a name, a description, a number of menus it appears on, and both date and price ranges.

Source: Kaggle
https://www.kaggle.com/nypl/whats-on-the-menu
