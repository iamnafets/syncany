/*
 * Syncany, www.syncany.org
 * Copyright (C) 2011-2015 Philipp C. Heckel <philipp.heckel@gmail.com> 
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.syncany.operations.daemon.messages;

import org.simpleframework.xml.Element;
import org.syncany.operations.daemon.messages.api.ManagementResponse;
import org.syncany.operations.init.ConnectOperationResult;

public class ConnectManagementResponse extends ManagementResponse {
	public static final int OK = 200;
	public static final int NOK_OPERATION_FAILED = 501;
	public static final int NOK_FAILED_TEST = 502;
	public static final int NOK_FAILED_UNKNOWN = 503;
	
	@Element(required = true)
	private ConnectOperationResult result;

	public ConnectManagementResponse() {
		// Nothing
	}
	
	public ConnectManagementResponse(int code, ConnectOperationResult result, int requestId) {
		super(code, requestId, null);
		this.result = result;
	}

	public ConnectOperationResult getResult() {
		return result;
	}
}
