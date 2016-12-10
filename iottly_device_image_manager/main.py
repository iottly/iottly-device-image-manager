"""

Copyright 2015 Stefano Terna

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

"""
import base64
import json
import logging
import os
import pytz
import random
import time
import tornado
import ujson
import urllib
import urlparse
import shutil

from datetime import datetime
from tornado import gen, autoreload, httpclient
import tornado.ioloop
import tornado.web
import tornado.auth
from tornado.httputil import url_concat
from tornado.escape import json_encode
from bson import json_util


from iottly_device_image_manager.util import module_to_dict, extract_request_dict
from iottly_device_image_manager.settings import settings

logging.getLogger().setLevel(logging.DEBUG)





class BaseHandler(tornado.web.RequestHandler):
    def get_current_user(self):
        return self.get_secure_cookie("user")


class GenerateImageHandler(BaseHandler):


    #@tornado.web.authenticated
    #@permissions.admin_only
    @gen.coroutine
    def post(self, _id):
        logging.info(_id)

        try:
            image_data = ujson.loads(self.request.body.decode('utf-8'))

            self.set_status(200)
            self.write(json.dumps(image_data, default=json_util.default))
            self.set_header("Content-Type", "application/json")

            time.sleep(5)

        except Exception as e:
            logging.error(e)
            self.set_status(500)
            error = {'error': '{}'.format(e)}
            self.write(json.dumps(error, default=json_util.default))
            self.set_header("Content-Type", "application/json")


def shutdown():
    pass

if __name__ == "__main__":
    app_settings = module_to_dict(settings)
    autoreload.add_reload_hook(shutdown)

    application = tornado.web.Application(
      [
        (r'/project/([0-9a-fA-F]{24})/generateimage', GenerateImageHandler),
      ], **app_settings)

    application.listen(8520)
    logging.info(" [*] Listening on 0.0.0.0:8520")

    tornado.ioloop.IOLoop.instance().start()
