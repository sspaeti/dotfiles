import argparse
import re
import requests
from bs4 import BeautifulSoup
import os

HEADERS = {
    "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
}

def is_email(text):
    return bool(re.match(r"^[^@\s]+@[^@\s]+\.[^@\s]+$", text))


def scrape_screener(cookies):
    page = 1
    denied_emails = []
    approved_emails = []

    with requests.Session() as session:
        while True:
            response = session.get(
                "https://app.hey.com/my/clearances",
                params={"page": page},
                cookies=cookies,
                headers=HEADERS,
            )
            soup = BeautifulSoup(response.text, "html.parser")

            for element in soup.select(".screened-person--denied"):
                email = element.select_one(".screened-person__details span")
                if email:
                    denied_emails.append(email.get_text(strip=True))

            for element in soup.select(".screened-person--approved"):
                email = element.select_one(".screened-person__details span")
                if email:
                    approved_emails.append(email.get_text(strip=True))

            next_page_link = soup.select_one(
                'a.paginator__next[href*="/my/clearances?page="]'
            )
            if not next_page_link:
                break
            page += 1

    return denied_emails, approved_emails


def scrape_cursor_paginated(base_url, email_selector, cookies, emails_only=False):
    emails = []
    url = base_url
    with requests.Session() as session:
        while url:
            response = session.get(url, cookies=cookies, headers=HEADERS)
            soup = BeautifulSoup(response.text, "html.parser")
            for el in soup.select(email_selector):
                text = el.get_text(strip=True).strip("<>")
                if text and text not in emails:
                    if emails_only and not is_email(text):
                        continue
                    emails.append(text)
            next_link = soup.select_one('a[data-pagination-target="nextPageLink"]')
            url = "https://app.hey.com" + next_link["href"] if next_link and next_link.get("href") else None
    return emails


def scrape_feed_emails(cookies):
    return scrape_cursor_paginated(
        "https://app.hey.com/feedbox",
        ".entry__sender-email",
        cookies,
    )


def scrape_paper_trail_emails(cookies):
    return scrape_cursor_paginated(
        "https://app.hey.com/paper_trail",
        ".posting__byline .posting__detail",
        cookies,
        emails_only=True,
    )


def write_to_file(filename, email_list):
    with open(filename, "w") as file:
        for email in email_list:
            file.write(f"{email}\n")


cookies = {
    # Copy all 4 cookies from DevTools Network tab on /my/clearances request.
    # Might need to update after re-login.
    "x_user_agent": os.getenv("HEY_X_USER_AGENT"),
    "device_token": os.getenv("HEY_DEVICE_TOKEN"),
    "session_token": os.getenv("HEY_SESSION_TOKEN"),
    "_haystack_session": os.getenv("HEY_HAYSTACK_SESSION"),
}

parser = argparse.ArgumentParser()
parser.add_argument("--feed", action="store_true")
parser.add_argument("--paper", action="store_true")
parser.add_argument("--screener", action="store_true")
args = parser.parse_args()

# default: run all
run_all = not any([args.feed, args.paper, args.screener])

if run_all or args.screener:
    denied_emails, approved_emails = scrape_screener(cookies)
    write_to_file("denied_emails.txt", denied_emails)
    write_to_file("approved_emails.txt", approved_emails)
    print(f"Denied: {len(denied_emails)}, Approved: {len(approved_emails)}")

if run_all or args.feed:
    feed_emails = scrape_feed_emails(cookies)
    write_to_file("feed_emails.txt", feed_emails)
    print(f"Feed Emails ({len(feed_emails)}):", feed_emails)

if run_all or args.paper:
    paper_trail_emails = scrape_paper_trail_emails(cookies)
    write_to_file("paper_trail_emails.txt", paper_trail_emails)
    print(f"Paper Trail Emails ({len(paper_trail_emails)}):", paper_trail_emails)
