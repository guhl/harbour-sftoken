/*
  Copyright (C) 2017 Guhl.
  Contact: Guhl <guhl@dershampoonierte.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include "stokencommon.h"
#include <time.h>
#include <QDebug>

StokenCommon::StokenCommon(QObject *parent) : QObject(parent)
  , m_current_token(NULL)
  , m_initialized(false)
  , m_token_days_left(0)
  , m_token_interval(0)
  , m_token_uses_pin(0)
  , m_err_string("")
  , m_token_string("")
  , m_next_token_string("")
  , m_pin("0000")
  , m_token_serial("")
  , m_expiration_date("")
  , m_data_location("")
{
}

QString StokenCommon::token_string()
{
    char *buf=(char *)malloc(BUFLEN);
    std::stringstream ss;
    time_t now;
    if (m_current_token)
    {
        now = adjusted_time(m_current_token, 0, 0);
        securid_compute_tokencode(m_current_token, now, buf);
        ss << buf;
        setToken_string(QString::fromStdString(ss.str()));
    }
    return m_token_string;
}

void StokenCommon::setToken_string(const QString &token_string)
{
    if (token_string != m_token_string ) {
        m_token_string = token_string;
        emit token_stringChanged();
    }
}

QString StokenCommon::next_token_string()
{
    char *buf=(char *)malloc(BUFLEN);
    std::stringstream ss;
    time_t now;
    if (m_current_token)
    {
        now = adjusted_time(m_current_token, 0, 0) + m_token_interval;
        securid_compute_tokencode(m_current_token, now, buf);
        ss << buf;
        setNext_token_string(QString::fromStdString(ss.str()));
    }
    return m_next_token_string;
}

void StokenCommon::setNext_token_string(const QString &next_token_string)
{
    if (next_token_string != m_next_token_string ) {
        m_next_token_string = next_token_string;
        emit next_token_stringChanged();
    }
}

void StokenCommon::setToken_days_left(const qint16 &d)
{
    if (d != (qint16)m_token_days_left) {
        m_token_days_left = (int)d;
        emit token_days_leftChanged();
    }
}

void StokenCommon::setPin(const QString &pin)
{
    if (pin == QString(""))
        m_pin = "0000";
    else
        m_pin = pin;
    if (m_current_token)
    {
        xstrncpy(m_current_token->pin, m_pin.toLocal8Bit().constData() , MAX_PIN + 1);
    }
}

char* StokenCommon::xstrdup(const char *s)
{
    char *ret = strdup(s);
    return ret;
}

void StokenCommon::xstrncpy(char *dest, const char *src, size_t n)
{
    strncpy(dest, src, n);
    dest[n - 1] = 0;
}

void* StokenCommon::xmalloc(size_t size)
{
    void *ret = malloc(size);
    return ret;
}

void* StokenCommon::xzalloc(size_t size)
{
    void *ret = xmalloc(size);
    memset(ret, 0, size);
    return ret;
}

int StokenCommon::decode_rc_token(struct stoken_cfg *cfg, struct securid_token *t)
{
    int rc = securid_decode_token(cfg->rc_token, t);

    if (rc != ERR_NONE) {
        qDebug() << "rcfile: token data is garbled, ignoring";
        return rc;
    }

    if (cfg->rc_pin) {
        if (t->flags & FL_PASSPROT)
            t->enc_pin_str = xstrdup(cfg->rc_pin);
        else {
            if (securid_pin_format_ok(cfg->rc_pin) == ERR_NONE)
                xstrncpy(t->pin, cfg->rc_pin, MAX_PIN + 1);
            else
                qDebug() << "rcfile: invalid PIN format";
        }
    }
    return ERR_NONE;
}

void StokenCommon::token_init()
{
    m_data_location = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    qDebug() << "m_data_location=" << m_data_location;

    std::stringstream ss;

    if (common_init())
    {
        m_err_string = "Unable to initialize crypto library.";
        qDebug() << m_err_string;
        m_initialized = false;
    } else {
        if (!m_current_token)
        {
            m_err_string = "Missing token, Please import token!";
            qDebug() << m_err_string;
            m_initialized = false;
        } else {
            setToken_days_left((qint16) securid_check_exp(m_current_token, time(NULL)) );
            setToken_interval((qint16) securid_token_interval(m_current_token) );
            setToken_uses_pin((qint16) securid_pin_required(m_current_token) );
            securid_decrypt_seed(m_current_token, NULL, NULL);

            ss << m_current_token->serial;
            m_token_serial = QString::fromStdString(ss.str());

            time_t exp_unix_time = securid_unix_exp_date(m_current_token);
            m_expiration_date = QDateTime::fromTime_t(exp_unix_time).toUTC().toString("yyyy.MM.dd");

//            securid_token_info(m_current_token);
            m_initialized = true;
        }
    }
}

int StokenCommon::common_init()
{
    char* opt_rcfile;
    QString cfgLocation = QDir::cleanPath(m_data_location + QDir::separator() + ".stokenrc");

    opt_rcfile = strdup(cfgLocation.toLocal8Bit().constData());

    m_cfg = (stoken_cfg*) xzalloc(sizeof(*m_cfg));
    if (__stoken_read_rcfile(opt_rcfile, m_cfg, &warn) != ERR_NONE)
        __stoken_zap_rcfile_data(m_cfg);

    if (m_cfg->rc_ver && atoi(m_cfg->rc_ver) != RC_VER) {
        warn("rcfile: version mismatch, ignoring contents\n");
        __stoken_zap_rcfile_data(m_cfg);
    }

    struct securid_token *t;
    t = (securid_token*)xzalloc(sizeof(struct securid_token));
    if (m_cfg->rc_token) {
        if (decode_rc_token(m_cfg, t) == ERR_NONE) {
            m_current_token = t;
        }
    } else {
        free(t);
        free(m_current_token);
        m_current_token = NULL;
    }

    return ERR_NONE;
}

time_t StokenCommon::adjusted_time(struct securid_token *t, int opt_next, long opt_use_time)
{
    time_t now = time(NULL);

    if (opt_next && opt_use_time)
        qDebug() << "error: opt_next and opt_use_time are mutually exclusive";
    if (opt_next)
        return now + securid_token_interval(t);

    if (!opt_use_time)
        return now;
    else
        return now + opt_use_time;

    qDebug() << "error: invalid opt_use_time=" << opt_use_time;
    return 0;
}

void StokenCommon::securid_token_info(const struct securid_token *t)
{
    char str[256];
    unsigned int i;
    struct tm exp_tm;
    time_t exp_unix_time = securid_unix_exp_date(t);
    std::stringstream ss;

    ss << t->serial;
    qDebug() << "Serial number" << QString::fromStdString(ss.str());

    if (t->has_dec_seed) {
        for (i = 0; i < AES_KEY_SIZE; i++)
            sprintf(&str[i * 3], "%02x ", t->dec_seed[i]);
        qDebug() << "Decrypted seed" << str;
    }

    if (t->has_enc_seed) {
        for (i = 0; i < AES_KEY_SIZE; i++)
            sprintf(&str[i * 3], "%02x ", t->enc_seed[i]);
        qDebug() << "Encrypted seed" << str;

        qDebug() << "Encrypted w/password" <<
            (t->flags & FL_PASSPROT ? "yes" : "no");
        qDebug() << "Encrypted w/devid" <<
            (t->flags & FL_SNPROT ? "yes" : "no");
    }

    gmtime_r(&exp_unix_time, &exp_tm);
    strftime(str, 32, "%Y/%m/%d", &exp_tm);
    qDebug() << "Expiration date" << str;

    qDebug() << "Key length" <<  (t->flags & FL_128BIT ? "128" : "64");

    sprintf(str, "%d",
        ((t->flags & FLD_DIGIT_MASK) >> FLD_DIGIT_SHIFT) + 1);
    qDebug() << "Tokencode digits" << str;

    sprintf(str, "%d",
        ((t->flags & FLD_PINMODE_MASK) >> FLD_PINMODE_SHIFT));
    qDebug() << "PIN mode" << str;

    switch ((t->flags & FLD_NUMSECONDS_MASK) >> FLD_NUMSECONDS_SHIFT) {
    case 0x00:
        strcpy(str, "30");
        break;
    case 0x01:
        strcpy(str, "60");
        break;
    default:
        strcpy(str, "unknown");
    }
    qDebug() << "Seconds per tokencode" << str;

    qDebug() << "App-derived" << (t->flags & FL_APPSEEDS ? "yes" : "no");
    qDebug() << "Feature bit 4" << (t->flags & FL_FEAT4 ? "yes" : "no");
    qDebug() << "Time-derived" << (t->flags & FL_TIMESEEDS ? "yes" : "no");
    qDebug() << "Feature bit 6" << (t->flags & FL_FEAT6 ? "yes" : "no");
}

bool StokenCommon::importToken(const QString& f){
    int rc;
    char *file;
    struct securid_token *t;
    char buf[BUFLEN];

    QUrl url(f);
    t = (securid_token*)xzalloc(sizeof(struct securid_token));
    file = strdup(url.toLocalFile().toLocal8Bit().constData());
    rc = read_token_from_file(file, t);
    if (rc == ERR_MULTIPLE_TOKENS)
    {
        m_err_string = "error: multiple tokens found; use 'stoken split' to create separate files!";
        qDebug() << m_err_string;
        free(t);
        return false;
    } else if (rc != ERR_NONE) {
        m_err_string = "error: no valid token in file!";
        qDebug() << m_err_string;
        free(t);
        return false;
    }
    current_token = t;
    t->is_smartphone = 0;
    securid_encode_token(t, NULL, NULL, 2, buf);
    rc = write_token_and_pin(buf, NULL, NULL);
    if (rc != ERR_NONE)
    {
        m_err_string = "rcfile: error writing new token!";
        qDebug() << m_err_string;
        return false;
    } else {
        return true;
    }
}

int StokenCommon::read_token_from_file(char *filename, struct securid_token *t)
{
    char buf[65536], *p;
    int rc = ERR_BAD_LEN;
    FILE *f;
    size_t len;

    f = fopen(filename, "r");
    if (f == NULL)
        return ERR_FILE_READ;

    len = fread(buf, 1, sizeof(buf) - 1, f);
    if (ferror(f))
        len = 0;
    fclose(f);

    if (len == 0)
        return ERR_FILE_READ;
    buf[len] = 0;

    for (p = buf; *p; ) {
        rc = __stoken_parse_and_decode_token(p, t, 1);

        /*
         * keep checking more lines until we find something that
         * looks like a token
         */
        if (rc != ERR_GENERAL)
            break;

        p = strchr(p, '\n');
        if (!p)
            break;
        p++;
    }

    return rc;
}

int StokenCommon::write_token_and_pin(char *token_str, char *pin_str, char *password)
{
    char* opt_rcfile = NULL;
    QDir cfgDir(m_data_location);
    if (!cfgDir.exists()) {
        cfgDir.mkpath(".");
    }
    QString cfgLocation = QDir::cleanPath(m_data_location + QDir::separator() + ".stokenrc");
    opt_rcfile = strdup(cfgLocation.toLocal8Bit().constData());

    free(m_cfg->rc_ver);
    free(m_cfg->rc_token);
    free(m_cfg->rc_pin);
    m_cfg = (stoken_cfg*) xzalloc(sizeof(*m_cfg));

    m_cfg->rc_token = xstrdup(token_str);

    if (pin_str && !password)
        m_cfg->rc_pin = xstrdup(pin_str);
    else if (pin_str && password) {
        m_cfg->rc_pin = securid_encrypt_pin(pin_str, password);
        if (!m_cfg->rc_pin)
            return ERR_GENERAL;
    } else
        m_cfg->rc_pin = NULL;

    m_cfg->rc_ver = xstrdup("1");

    return __stoken_write_rcfile(opt_rcfile, m_cfg, &warn);
}
