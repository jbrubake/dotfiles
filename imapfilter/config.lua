-- get_pass() taken from nicodebo
-- https://github.com/nicodebo/dotfiles/blob/master/imapfilter/config.lua
--
-- Gets the password associated with <account> from a pass(1) store
-- The password must be stored in oauth/<account>
--
function get_pass(account)
    local cmd = string.format('pass oauth/%s', account)
    return (assert(io.popen(cmd, 'r'))):read()
end

-- According to the IMAP specification, when trying to write a message
-- to a non-existent mailbox, the server must send a hint to the client,
-- whether it should create the mailbox and try again or not. However
-- some IMAP servers don't follow the specification and don't send the
-- correct response code to the client. By enabling this option the
-- client tries to create the mailbox, despite of the server's response.
-- This variable takes a boolean as a value.  Default is “false”.
options.create = true
-- By enabling this option new mailboxes that were automatically created,
-- get auto subscribed
options.subscribe = true
-- How long to wait for servers response.
options.timeout = 120

local jbru362_gmail_com = IMAP {
    server = 'imap.gmail.com',
    username = 'jbru362@gmail.com',
    password = get_pass('jbru362@gmail.com'),
    ssl = 'ssl3'
}

local jeremy_d_brubaker_gmail_com = IMAP {
    server = 'imap.gmail.com',
    username = 'jeremy.d.brubaker',
    password = get_pass('jeremy.d.brubaker@gmail.com'),
    ssl = 'ssl3'
}

jeremy_d_brubaker_gmail_com.INBOX:check_status ()
jbru362_gmail_com.INBOX:check_status ()
