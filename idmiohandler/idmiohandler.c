/*
 * IdmIOHandler
 * ------------
 * Workaround to fix serial port transmittions
 * on Flutter app (idm_ui)
 */

#include <errno.h>
#include <libserialport.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int put_request(const char *portname, const char *req) {
  struct sp_port *port;
  struct sp_port_config *config;
  enum sp_return retsp;
  int ret;

  retsp = sp_get_port_by_name(portname, &port);
  if (retsp != SP_OK)
    return ENODEV;

  if (strcmp(sp_get_port_usb_manufacturer(port), "Silicon Labs")) {
    ret = EINVAL;
    goto err_open;
  }

  retsp = sp_open(port, SP_MODE_READ_WRITE);
  if (retsp != SP_OK) {
    ret = EBUSY;
    goto err_open;
  }

  retsp = sp_new_config(&config);
  if (retsp != SP_OK) {
    ret = ENOMEM;
    goto err;
  }

  retsp = sp_get_config(port, config);
  if (retsp != SP_OK) {
    ret = EINVAL;
    goto err;
  }

  retsp = sp_set_config_baudrate(config, 57600);
  if (retsp != SP_OK) {
    ret = EINVAL;
    goto err;
  }

  retsp = sp_set_config(port, config);
  if (retsp != SP_OK) {
    ret = EINVAL;
    goto err;
  }

  retsp = sp_blocking_write(port, req, strlen(req), 1000);
  if (retsp != strlen(req)) {
    ret = EIO;
    goto err;
  }

  sp_close(port);
  sp_free_port(port);
  sp_free_config(config);
  return 0;

err:
  sp_close(port);
  sp_free_config(config);
err_open:
  sp_free_port(port);

  return ret;
}

int get_request(const char *portname) {
  struct sp_port *port;
  struct sp_port_config *config;
  char buf[2097152]; // 2MB to be sure that we can send image
  enum sp_return retsp;
  int ret;

  retsp = sp_get_port_by_name(portname, &port);
  if (retsp != SP_OK)
    return ENODEV;

  if (strcmp(sp_get_port_usb_manufacturer(port), "Silicon Labs")) {
    ret = EINVAL;
    goto err_open;
  }

  retsp = sp_open(port, SP_MODE_READ_WRITE);
  if (retsp != SP_OK) {
    ret = EBUSY;
    goto err_open;
  }

  retsp = sp_new_config(&config);
  if (retsp != SP_OK) {
    ret = ENOMEM;
    goto err;
  }

  retsp = sp_get_config(port, config);
  if (retsp != SP_OK) {
    ret = EINVAL;
    goto err;
  }

  retsp = sp_set_config_baudrate(config, 57600);
  if (retsp != SP_OK) {
    ret = EINVAL;
    goto err;
  }

  retsp = sp_set_config(port, config);
  if (retsp != SP_OK) {
    ret = EINVAL;
    goto err;
  }

  int i = -1;

  sp_flush(port, SP_BUF_BOTH);

  while (buf[i] != '\n') {
    i++;
    retsp = sp_blocking_read(port, &buf[i], 1, 0);
  }

  buf[i + 1] = '\0';

  printf("%s\n", buf);

  sp_close(port);

  sp_free_port(port);
  sp_free_config(config);
  return 0;

err:
  sp_close(port);
  sp_free_config(config);
err_open:
  sp_free_port(port);

  return ret;
}

int main(int argc, char const *argv[]) {

  if (argc != 3) {
    return EINVAL;
  }

  char *port = "/dev/ttyUSB0";
  char *data;

  put_request(argv[1], argv[2]);

  get_request(argv[1]);

  return 0;
}
