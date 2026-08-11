========================================
  READ ME FIRST — GoDaddy full replace
========================================

This zip is the COMPLETE working website for elessons.net.
Extract it into public_html so these files sit at the TOP level.

HOW TO REPLACE EVERYTHING (cPanel)
---------------------------------
1. Open File Manager → public_html
2. Select ALL current files/folders and DELETE them
   (or move them to a backup folder outside public_html)
3. Upload this zip into the now-empty public_html
4. Right-click the zip → Extract
5. Delete the zip after extract
6. Click Settings → enable "Show Hidden Files"
7. Confirm you see:  .htaccess   index.html   course-detail.html
8. Visit https://elessons.net/ and hard-refresh (Ctrl+F5)

CORRECT RESULT
--------------
public_html/
  .htaccess
  index.html
  course-detail.html
  about.html
  assets/
  css/
  js/
  images/
  pdfs/
  ...

WRONG (do not leave it like this)
---------------------------------
public_html/public/index.html
public_html/lib/
public_html/android/

WHAT WORKS AFTER THIS UPLOAD
----------------------------
✓ Homepage
✓ Demo video (eLessons Drive clip, not random YouTube)
✓ Classes / Enroll → course-detail.html
✓ About, Terms, Privacy, Checkout
✓ HTTPS + www → non-www redirects (.htaccess)
✓ Cart / WhatsApp enquire flow on course pages
✓ Full package + By subject purchase options
  (By module removed on purpose)

QUICK TESTS
-----------
https://elessons.net/
https://elessons.net/#demo
https://elessons.net/#courses
https://elessons.net/course-detail.html?grade=10&plan=subject&subject=maths
https://elessons.net/about.html
