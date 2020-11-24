ALTER TABLE login
	ADD COLUMN block BOOL not null default false;

CREATE OR REPLACE FUNCTION user_to_black_list(p_phone text)
							RETURNS Void
AS $$
BEGIN
		UPDATE login
			SET block = true
		WHERE phone = p_phone;
END;
$$ LANGUAGE 'plpgsql';