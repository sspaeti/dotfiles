import requests
from bs4 import BeautifulSoup
import os


def scrape_emails(url, cookies):
    page = 1
    denied_emails = []
    approved_emails = []

    with requests.Session() as session:
        while True:
            response = session.get(url, params={"page": page}, cookies=cookies)
            soup = BeautifulSoup(response.text, "html.parser")

            # Extract emails
            for element in soup.select(".screened-person--denied"):
                email = element.select_one(".screened-person__details span")
                if email:
                    denied_emails.append(email.get_text(strip=True))

            for element in soup.select(".screened-person--approved"):
                email = element.select_one(".screened-person__details span")
                if email:
                    approved_emails.append(email.get_text(strip=True))

            # Check for the 'Older' button/link
            next_page_link = soup.select_one(
                'a.paginator__next[href*="/my/clearances?page="]'
            )
            if not next_page_link:
                break  # No more pages

            page += 1
            # if page == 3:
            #     break

    return denied_emails, approved_emails


def write_to_file(filename, email_list):
    with open(filename, "w") as file:
        for email in email_list:
            file.write(f"{email}\n")


cookies = {
    # Set ENV variable with hey cookie. Load the screener and search in network tab for `https://app.hey.com/my/clearances?page=` request.
    # There you see the cookies used. Might need to change after re-login
    "_csrf_token": os.getenv("HEY_COOKIE"),
}


url = "https://app.hey.com/my/clearances"
denied_emails, approved_emails = scrape_emails(url, cookies)

# Write the lists to files
write_to_file("denied_emails.txt", denied_emails)
write_to_file("approved_emails.txt", approved_emails)

print("Denied Emails:", denied_emails)
print("Approved Emails:", approved_emails)
