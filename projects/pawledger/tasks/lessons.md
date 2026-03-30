# Lessons Learned

_Updated after each user correction. Rules to prevent repeat mistakes._

- Any new navbar link must be checked against `App.jsx` route registration in the same PR; unmatched route links can silently render blank pages.
- Any new contract hook dependency (`pawAdoption`, `pawLedger`, `pawToken`) must be verified in `useContract` return shape; adding a hook without provider wiring causes runtime `Contract not connected` errors.
