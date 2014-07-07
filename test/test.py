import subprocess
import sys
import shlex
import signal
import os

process = None
def main():
    global process
    cwd = os.path.dirname(os.path.realpath(__file__))
    command = os.path.join(cwd, '..', 'npmws.sh')

    if os.environ.get('TRAVIS') or os.environ.get('CI'):
        print 'travis detected'
        fp = open(command, 'r')
        original = fp.read()
        fp.close()
        new = original.replace('ftp.kaist.ac.kr', 'sfo1.mirrors.digitalocean.com')
        fp = open(command, 'w')
        fp.write(new)
        fp.close()

    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE,
                               stdin=subprocess.PIPE, bufsize=0,
                               preexec_fn=os.setsid)
    def write_string(stdin, string):
        stdin.write(string)
        string = string.replace("\n", "\\n")
        sys.stdout.write(' \033[1m[send a key: ' + string + "]\033[0m ")
        sys.stdout.flush()

    while True:
        nextline = ''
        # process.stdout.readline does not wait if newline character is not
        # detected
        while True:
            char = process.stdout.read(1)
            nextline += char
            if char == ':' or char == '?' or char == '\n':
                break
        sys.stdout.write("line: " + nextline)
        print '] ?' in nextline
        sys.stdout.flush()
        if process.poll() != None:
            break
        elif 'Enter:' in nextline:
            write_string(process.stdin, '1\n') 
        elif '(y/n)' in nextline:
            write_string(process.stdin, 'y\n')
        elif '] :' in nextline or '] ?' in nextline:  # APC or else
            write_string(process.stdin, '\n')
        elif 'Installed' in nextline:
            break

        sys.stdout.flush()

    do_test(process.returncode)

def do_test(code):
    nginx_path = '/etc/nginx'
    php5_path = '/etc/php5/fpm'
    mariadb_path = '/etc/mysql'
    pma_path = '/usr/share/nginx/html/phpmyadmin'
    
    command = '/usr/bin/env php -r "phpinfo();"'
    p = subprocess.Popen(shlex.split(command), stdout=subprocess.PIPE)
    phpinfo = p.communicate()[0]

    assert os.path.isdir(nginx_path), 'nginx path does not exist'
    assert os.path.isdir(php5_path), 'php5-fpm path does not exist'
    assert os.path.isdir(mariadb_path), 'mariadb path does not exist'
    assert os.path.isdir(pma_path), 'phpMyAdmin path does not exist'
    assert 'apc' in phpinfo, 'PHP-APC may not installed correctly'
    assert 'mysql' in phpinfo, 'PHP-MySQL may not installed correctly'
    try:
        import urllib
        urllib.urlopen('http://127.0.0.1')
    except:
        assert False, 'nginx daemon may not started correctly'

    print 'All test passed!'
    exit(0)

if __name__ == '__main__':
    print os.environ
    try:
        main()
    except KeyboardInterrupt:
        if process is not None:
            os.killpg(process.pid, signal.SIGKILL)

