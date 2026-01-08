import { EvershopRequest } from '../../../../types/request.js';
import updateProductAttribute from '../../services/attribute/updateProductAttribute.js';

export default async (request: EvershopRequest, response) => {
  const result = await updateProductAttribute(
    request.params.id,
    request.body,
    {}
  );
  return result;
};
