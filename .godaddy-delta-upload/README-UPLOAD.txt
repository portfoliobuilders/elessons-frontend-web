G-TEC eLessons — PENDING UPDATES FOR GODADDY (v54)
=================================================

Compared live https://elessons.net/ with recent local work.

NOT YET ON LIVE (included here)
1) Course buttons broken — Add to cart / cart / WhatsApp
   Cause: detail.js shadowed function cur() inside repaint()
   Fix: var code + runStep hardening (Mentorship copy kept)
2) course_detail.html out of sync with course-detail.html
   Both now identical and point at ?v=54
3) Contact form dead on homepage (Send message was type=button, no <form>)
   Now real mailto form id=contact-form

ALREADY ON LIVE (kept / not replaced with older local)
- Maths/Chemistry banners (hashes matched)
- Mentorship branding + By module removed on course-detail
- Live Mentorship course-data.js (local still had Live+Recorded / By Module)

UPLOAD (cPanel → public_html)
1. Upload elessons-godaddy-pending-updates.zip
2. Extract INTO public_html (overwrite when asked)
3. Delete the zip after extract
4. Hard-refresh (Ctrl+F5)

TEST
- https://elessons.net/course-detail.html?grade=10&plan=subject&subject=maths
- https://elessons.net/course_detail.html?grade=10&plan=subject&subject=maths
- https://elessons.net/#contact