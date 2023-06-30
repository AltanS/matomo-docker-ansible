from ansible.plugins.lookup import LookupBase
from dotenv import load_dotenv, find_dotenv
import os

class LookupModule(LookupBase):

    def run(self, terms, variables=None, **kwargs):
        dotenv_path = find_dotenv(raise_error_if_not_found=True)
        load_dotenv(dotenv_path)

        ret = []
        for term in terms:
            ret.append(os.environ.get(term, None))
        return ret
