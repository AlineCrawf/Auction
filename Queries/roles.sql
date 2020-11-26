DROP ROLE Admin;
DROP ROLE Expert;
DROP ROLE Seller;
DROP ROLE Customer;

CREATE ROLE Admin with LOGIN PASSWORD 'AdMin';
CREATE ROLE Expert with LOGIN PASSWORD 'ExPeRt';
CREATE ROLE Seller with LOGIN PASSWORD 'qwerty';
CREATE ROLE Customer with LOGIN PASSWORD 'CuStOmEr';

GRANT CONNECT ON DATABASE "Auction" TO Seller;

--REVOKE ALL ON database "Auction" FROM PUBLIC;    		-- Для разгранечния прав